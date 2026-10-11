import argparse
import os
import struct
import subprocess
import tempfile

from tqdm import tqdm
from PIL import Image

from . import plot_image
from .exceptions import ArgumentError


NUM_AMIGA_CHANNELS = 4


def _read_value(proc, struct_type, value_name):
    try:
        b = proc.stdout.read(struct.calcsize(struct_type))
    except struct.error as e:
        print('Error reading {}: {}'.format(value_name, e))
        proc.kill()
        proc.communicate()
        proc.wait()
        return None
    if len(b) == 0:
        print('Premature eof detected when reading struct', struct_type,
              'value', value_name)
        proc.kill()
        proc.communicate()
        proc.wait()
        return None
    return struct.unpack(struct_type, b)[0]


def _create_colors_file():
    colors_f = tempfile.NamedTemporaryFile()
    color_bytes = bytearray()
    colors_dict = plot_image.COLORS
    for unused_index, color_tuple in sorted(colors_dict.items()):
        # Store colors in memory in the byte order: r, g, b, a. The C++
        # accelerator is not concerned with the color value memory layout,
        # so it just takes these values serialized here as big-endian.
        color = ((color_tuple[0] << 24) +
                 (color_tuple[1] << 16) +
                 (color_tuple[2] << 8) +
                 255)
        color_bytes.extend(struct.pack('>I', color))
    ret = colors_f.write(color_bytes)
    assert ret == len(color_bytes)
    colors_f.flush()
    return colors_f, len(colors_dict)


def run_accelerator(main_args=None) -> int:
    # TODO: the main function makes no sense anymore. Make this a normal
    # function that does not use ArgumentParser.
    parser = argparse.ArgumentParser()
    parser.add_argument('--aa-factor', type=int)
    parser.add_argument('file', nargs='*',
                        help='Register dump file (.reg) produced by uadecode.')
    parser.add_argument('--accelerator', required=True)
    parser.add_argument('--batch', action='store_true')
    parser.add_argument(
        '--color-mode', type=int, default=2, choices=plot_image.COLOR_MODES,
        help=('Enable coloring and set palette with --color-mode x '
              'where 0 <= x <= {}. If x == 0, no coloring is done.'.format(
                  max(plot_image.COLOR_MODES))))
    parser.add_argument(
        '--color-seed', type=int,
        help='Seeds the random generator for the color generation')
    parser.add_argument('--color-test-image', action='store_true')
    parser.add_argument('--csv-file')
    parser.add_argument('--fps', type=int, default=60, help='Set framerate')
    parser.add_argument('--fullscreen', '-f', action='store_true')
    parser.add_argument('--height', type=int, default=720)
    parser.add_argument('--image-prefix', default='output_')
    parser.add_argument('--image-format', default='png')
    parser.add_argument('--manual', action='store_true')
    parser.add_argument('--no-images', action='store_true')
    parser.add_argument('--no-antialiasing', action='store_true',
                        help='Disable antialiasing')
    parser.add_argument(
        '--line-width', default='2.0',
        help=('Set line width for drawing oscilloscope waveforms. '
              'This is only effective if antialiasing is used.'))
    parser.add_argument('--panning', type=float, default=0.7)
    parser.add_argument('--sampling-rate', default=44100)
    parser.add_argument('--sdl', action='store_true')
    parser.add_argument('--target-dir')
    parser.add_argument('--verbose', action='store_true')
    parser.add_argument('--wave')
    parser.add_argument('--width', type=int, default=1280)
    parser.add_argument('--write-audio-fd', type=int, default=-1)

    args = parser.parse_args(args=main_args)

    plot_image.init_colors(args.color_mode, args.color_seed)

    # TODO: pass colors as command line arguments, not through a file
    colors_f, num_colors = _create_colors_file()

    cmd = [
        args.accelerator,
        '--fps', str(args.fps),
        '--panning', str(args.panning),
        '--colors', str(num_colors), colors_f.name,
        '--width', str(args.width),
        '--height', str(args.height),
        '--line-width', args.line_width,
    ]

    if args.aa_factor is not None:
        cmd.extend(['--aa-factor', str(args.aa_factor)])

    if args.csv_file is not None:
        cmd.extend(['--csv-file', args.csv_file])

    if args.fullscreen:
        cmd.append('--fullscreen')

    if args.no_antialiasing:
        cmd.append('--no-antialiasing')

    if args.no_images:
        cmd.append('--no-video')

    if args.sdl:
        cmd.append('--sdl')

    if args.wave is not None:
        cmd.extend(['--wave', args.wave])

    keep_fds = []
    if len(args.file) > 0:
        assert len(args.file) == 1
        cmd.append(args.file[0])
    elif args.write_audio_fd >= 0:
        cmd.extend(['--write-audio-fd', str(args.write_audio_fd)])
        keep_fds.append(args.write_audio_fd)

        # The fd will be used by write_audio.cc, so it must be made inheritable
        os.set_inheritable(args.write_audio_fd, True)
    else:
        raise ValueError('No file or fd given')

    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, pass_fds=keep_fds)

    if not args.sdl:
        if args.target_dir is None:
            raise ArgumentError('--target-dir is required')

        assert os.path.isdir(args.target_dir)

        if args.wave is None:
            raise ArgumentError('--wave is required')

        num_frames = _read_value(proc, 'N', 'num_frames')
        if num_frames is None:
            return False

        progress_bar = None
        if num_frames > 0:
            progress_bar = tqdm(total=num_frames, disable=args.batch)

        num_images = 0

        FRAMEBUFFER_SIZE = 4 * args.width * args.height

        im = None
        if not args.no_images and args.image_format == 'png':
            im = Image.new(mode='RGBA', size=(args.width, args.height))

        while True:
            framebuffer = proc.stdout.read(FRAMEBUFFER_SIZE)
            if len(framebuffer) == 0:
                break
            assert len(framebuffer) == FRAMEBUFFER_SIZE

            if not args.no_images:
                if args.image_format == 'png':
                    im.frombytes(data=framebuffer)
                    if args.manual:
                        print('image frame', num_images)
                        im.show()
                        input('Enter to continue...')

                basename = '{}{:06d}.{}'.format(
                    args.image_prefix, num_images, args.image_format)
                image_path = os.path.join(args.target_dir, basename)

                if im is None:
                    with open(image_path, 'wb') as f:
                        f.write(framebuffer)
                else:
                    im.save(image_path, args.image_format, compress_level=1)

            num_images += 1

            if num_frames > 0:
                progress_bar.update(1)

    proc.communicate()

    ret_code = proc.wait()

    # Closing the file causes it to be deleted as it is a temporary file, so
    # we delete it after it has been used by the accelerator.
    colors_f.close()

    return ret_code
