# TODO: Figure out a faster ffmpeg video mode

import argparse
import ast
from multiprocessing import cpu_count, Pool
import os
import os.path
import pathlib
import random
import shutil
import signal
import socket
import subprocess
import tempfile
import time
import traceback
from typing import List

from . import write_audio
from .exceptions import ArgumentError

TMP_PREFIX = '_ignore_tmp_'
DEFAULT_FFMPEG_VIDEO_ARGS = ['-pix_fmt', 'yuv420p']

default_sigint_handler = None

UADE_RET_SONG_END = 0
UADE_RET_UNEXPECTED_ERROR = 1
UADE_RET_QUIT = 16
UADE_RET_NEXT = 17
UADE_RET_INVALID_SONG = 18


def sigint_handler(unused_signum, unused_frame):
    pass


def _get_target_dir(songfile: str, args):
    if args.base_dir is None:
        return pathlib.Path(args.target_dir)
    base_dir = pathlib.Path(args.base_dir).absolute()
    target_dir = pathlib.Path(args.target_dir).absolute()
    song_dir = pathlib.Path(songfile).absolute().parent
    try:
        relative_path = song_dir.relative_to(base_dir)
    except ValueError:
        print('Warning: {} is not relative to {}'.format(song_dir, base_dir))
        return target_dir
    return target_dir.joinpath(relative_path)


def _encode_audio(encoded_audio_file: str, wave_file: str, args):
    if args.save_audio == 'mp3':
        cp = subprocess.run(['lame',
                             '-b', str(args.audio_bitrate),
                             wave_file,
                             encoded_audio_file],
                            capture_output=True)
        if cp.returncode != 0:
            print('lame failed. STDOUT:\n\n{}\nSTDERR:\n\n{}\n'.format(
                    cp.stdout.decode(), cp.stderr.decode()))
            print()
            print('Failed to encode audio for {}'.format(wave_file))
            return 1
    else:
        raise NotImplementedError('Encoding {} not implemented'.format(
            args.save_audio))
    return 0


def _parse_resolution(s: str):
    if s == '720p':
        return 1280, 720
    elif s == '1080p':
        return 1920, 1080

    fields = s.split('x')
    if len(fields) != 2:
        raise ArgumentError('Invalid resolution:', s)
    try:
        width, height = (int(fields[0]), int(fields[1]))
    except ValueError:
        raise ArgumentError('Invalid resolution:', s)

    return width, height


def _live(songfile: str,
          args,
          uade123_arg_list: List[str],
          write_audio_options_list: List[str]) -> int:
    width, height = _parse_resolution(args.resolution)

    line_width = args.line_width
    if line_width is None:
        line_width = str(2 * height / 720)

    read_socket, write_socket = socket.socketpair()
    uade123_cmd = [
        args.uade123,
        '-f', '/dev/null',
        '--write-audio-fd', str(write_socket.fileno()),
    ] + uade123_arg_list + [songfile]

    uade123_proc = None

    # Start uade123 on the background. uade123 writes register data
    # into write_socket fd. The accelerator will read the data from
    # read_socket and process the data in parallel with uade123.
    #
    # For this reason, the write_socket fd must be made inheritable.
    # Also, it must not be closed by Popen().
    #
    # read_socket will be made inheritable for the accelerator.
    os.set_inheritable(write_socket.fileno(), True)

    uade123_proc = subprocess.Popen(uade123_cmd,
                                    pass_fds=(write_socket.fileno(), ))
    # write_socket must be closed so that the reader detects EOF
    write_socket.close()

    write_audio_args = [
        '--fps', str(args.fps),
        '--width', str(width),
        '--height', str(height),
        '--line-width', line_width,
    ] + write_audio_options_list

    if args.no_antialiasing:
        write_audio_args.append('--no-antialiasing')

    if args.aa_factor is not None:
        write_audio_args.extend(['--aa-factor', str(args.aa_factor)])

    write_audio_args.append('--no-images')
    write_audio_args.append('--sdl')

    write_audio_args.extend(['--write-audio-fd',
                             str(read_socket.fileno())])

    if args.fullscreen:
        write_audio_args.append('--fullscreen')

    accelerator_ret = write_audio.run_accelerator(write_audio_args)

    read_socket.close()

    if uade123_proc is not None:
        uade123_proc.kill()
        uade123_proc.communicate()
        uade123_proc.wait()

    if accelerator_ret in (UADE_RET_SONG_END, UADE_RET_NEXT):
        # 0 is normal ending
        return 0
    elif accelerator_ret == UADE_RET_INVALID_SONG:
        print('Song {} was invalid'.format(songfile))
        return 0
    elif accelerator_ret == UADE_RET_UNEXPECTED_ERROR:
        print('write_audio returned an unexpected error')
        return 1
    elif accelerator_ret == UADE_RET_QUIT:
        # quit
        return accelerator_ret
    else:
        print('Unexpected return code: {}'.format(accelerator_ret))
        return 1

    assert False


def _process_songfile(songfile: str,
                      args,
                      uade123_arg_list: List[str],
                      write_audio_options_list: List[str]) -> int:
    width, height = _parse_resolution(args.resolution)

    line_width = args.line_width
    if line_width is None:
        line_width = str(2 * height / 720)

    with tempfile.TemporaryDirectory(prefix=TMP_PREFIX,
                                     dir=args.target_dir) as tmpdir:
        bname = os.path.basename(songfile)

        if args.write_audio_file:
            regfile = os.path.join(tmpdir, bname + '.reg')
        else:
            regfile = None

        if args.target_dir is None:
            target_dir = None
            video_path = None
            csv_path = None
            audio_path = None
        else:
            target_dir = _get_target_dir(songfile, args)
            video_path = os.path.join(target_dir, bname + '.mp4')
            csv_path = os.path.join(target_dir, bname + '.csv')
            audio_path = None
            if args.save_audio is not None:
                audio_path = os.path.join(target_dir, bname + '.' +
                                          args.save_audio)

        if args.no_overwrite and os.path.exists(video_path):
            print('Skip {} because {} exists'.format(songfile, video_path))
            return 0

        print('Generating register dump for {}...'.format(songfile))

        uade123_cmd = [args.uade123, '-f', '/dev/null'] + uade123_arg_list
        read_socket = None
        write_socket = None

        if regfile is None:
            # uadecore will write register data into write_socket, and the
            # accelerator will read the data from read_socket.
            read_socket, write_socket = socket.socketpair()

            uade123_cmd.extend(
                ['--write-audio-fd', str(write_socket.fileno())])
        else:
            uade123_cmd.extend(['--write-audio', regfile])

        uade123_cmd.append(songfile)

        uade123_proc = None

        if regfile is None:
            # Start uade123 on the background. uade123 writes register data
            # into write_socket fd. The accelerator will read the data from
            # read_socket and process the data in parallel with uade123.
            #
            # For this reason, the write_socket fd must be made inheritable.
            # Also, it must not be closed by Popen().
            #
            # read_socket will be made inheritable for the accelerator.
            os.set_inheritable(write_socket.fileno(), True)

            uade123_proc = subprocess.Popen(uade123_cmd,
                                            pass_fds=(write_socket.fileno(), ))
            # write_socket must be closed so that the reader detects EOF
            write_socket.close()
        else:
            # Run uade123 synchronously to generate a register dump file, which
            # is later processed by the accelerator.
            cp = subprocess.run(uade123_cmd, stdout=subprocess.DEVNULL)
            if cp.returncode != 0:
                print('Failed to play {}'.format(songfile))
                return 1

        wave_path = os.path.join(tmpdir, bname + '.wav')

        if args.base_dir is not None:
            os.makedirs(target_dir, exist_ok=True)

        target_files = []
        if not args.no_video:
            target_files.append('oscilloscope video: {}'.format(
                video_path))
        if args.save_audio is not None:
            target_files.append('audio file: {}'.format(audio_path))
        if args.csv_file:
            target_files.append('csv file: {}'.format(csv_path))

        print('Generating: {}'.format(' '.join(target_files)))

        write_audio_args = ['--target-dir', tmpdir,
                            '--wave', wave_path,
                            '--fps', str(args.fps),
                            '--width', str(width),
                            '--height', str(height),
                            '--line-width', line_width,
                            ] + write_audio_options_list

        if args.no_antialiasing:
            write_audio_args.append('--no-antialiasing')

        if args.aa_factor is not None:
            write_audio_args.extend(['--aa-factor', str(args.aa_factor)])

        if args.no_video:
            write_audio_args.append('--no-images')

        if args.csv_file:
            write_audio_args.extend(['--csv-file', csv_path])

        if regfile is None:
            write_audio_args.extend(['--write-audio-fd',
                                     str(read_socket.fileno())])
        else:
            write_audio_args.append(regfile)

        accelerator_ret = write_audio.run_accelerator(write_audio_args)

        if regfile is None:
            read_socket.close()

        if uade123_proc is not None:
            uade123_proc.kill()
            uade123_proc.communicate()
            uade123_proc.wait()

        if accelerator_ret != 0:
            print('write_audio.main() failed')
            return 1

        if args.save_audio is not None:
            assert os.path.exists(wave_path)
            tmp_audio_file = os.path.join(tmpdir,
                                          bname + '.' + args.save_audio)
            if args.save_audio == 'wav':
                shutil.copyfile(wave_path, audio_path)
            else:
                audio_ret = _encode_audio(tmp_audio_file, wave_path, args)
                if audio_ret != 0:
                    try:
                        os.remove(tmp_audio_file)
                    except OSError:
                        pass
                    return audio_ret
                # Atomic replace
                try:
                    os.replace(tmp_audio_file, audio_path)
                except OSError as e:
                    print('Unable to replace {}: {}'.format(
                        audio_path, e))
                    try:
                        os.remove(tmp_audio_file)
                    except OSError:
                        pass
                    return 1

        if not args.no_video:
            print('Generating video file {}'.format(video_path))

            image_pattern = os.path.join(tmpdir, 'output_%06d.{}'.format(
                args.image_format))

            video_temp_file = tempfile.NamedTemporaryFile(
                prefix=TMP_PREFIX, suffix='.mp4', dir=target_dir, delete=False)

            ffmpeg_cmd = [
                args.ffmpeg,
                '-i', wave_path,
            ]

            if args.image_format == 'raw':
                # These are needed for raw image dumps. PNG is handled
                # automatically.
                ffmpeg_cmd.extend([
                    '-f', 'image2',
                    '-s', '{}x{}'.format(width, height),
                    '-pix_fmt', 'rgba',
                ])

            ffmpeg_cmd.extend([
                '-framerate', str(args.fps),
                '-i', image_pattern,
                '-y',
            ])

            ffmpeg_cmd.extend(args.ffmpeg_video_args)

            ffmpeg_cmd.append(video_temp_file.name)

            cp = subprocess.run(ffmpeg_cmd, capture_output=True)

            if cp.returncode != 0:
                try:
                    os.remove(video_temp_file.name)
                except FileNotFoundError:
                    pass
                except OSError as e:
                    print('Unable to remove: {}'.format(e))

                print('ffmpeg failed. STDOUT:\n\n{}\n\nSTDERR:\n\n{}\n'.format(
                    cp.stdout.decode(), cp.stderr.decode()))
                print()
                print('Failed to create video for {}'.format(songfile))
                return 1

            # Atomic replace of the target file for easier snapshotting of
            # accumulated videos and avoid partial videos
            try:
                os.replace(video_temp_file.name, video_path)
            except OSError as e:
                print('Unable to replace {}: {}'.format(video_path, e))
                try:
                    os.remove(video_temp_file.name)
                except OSError:
                    pass
                return 1

    return 0


def _generate_video(*pos) -> int:
    try:
        return _process_songfile(*pos)
    except Exception as e:
        print('Job {} threw an exception: {}'.format(pos, e))
        traceback.print_exc()
        return 2


def _check_aa_factor(s):
    if s is None:
        return
    try:
        aa_factor = int(s)
    except ValueError:
        aa_factor = 0

    if aa_factor <= 0 or (aa_factor & (aa_factor - 1)) != 0:
        raise ValueError('--aa-factor must be a positive integer that is a '
                         'power of two')


def main(live: bool = False) -> int:
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('files', metavar='FILE', nargs='*')
    parser.add_argument('--aa-factor', type=int)
    parser.add_argument('--accelerator')
    parser.add_argument('--audio-bitrate', type=int, default=192)
    parser.add_argument(
        '--base-dir',
        help=('Write video files relative to target directory the same as the '
              'song file is relative to the given base dir. E.g. song file '
              '/foo/bar/song.mod and base dir /foo causes the video to be '
              'written as TARGET_DIR/bar/song.mod.mp4.'))
    parser.add_argument('--color-mode', type=int, default=2)
    parser.add_argument(
        '--color-seed', type=int,
        help='Seeds the random generator for the color generation')
    parser.add_argument(
        '--csv-file', action='store_true',
        help=('Generate a CSV file that contains waveforms that can be used '
              'to render oscilloscope views. '
              'The CSV file is generated under the same directory as the '
              'video file would be. '
              'With this you can implement your own '
              'renderer by using --csv-file and --save-audio wav. '
              'The CSV format has 6 columns. '
              '"frame" identifies the frame number starting from 0. '
              'With 60 fps, the first second has frame numbers 0..59. '
              '"channel" identifies the amiga channel (0-3). '
              '"x" is the x coordinate on screen pixels. '
              '"amplitude" is between [-1, 1). '
              '"normalizer" is a multiplier for amplitude that can optionally '
              'be used to  normalize the volume of the frame so that full '
              'dynamic range [-1, 1) is used.'
              ))
    # TODO: Add vorbis, opus, flac
    parser.add_argument('--save-audio', choices=['mp3', 'wav'])
    parser.add_argument('--ffmpeg', default='ffmpeg', help='Path to ffmpeg')
    parser.add_argument(
        '--ffmpeg-video-args', type=ast.literal_eval,
        default=DEFAULT_FFMPEG_VIDEO_ARGS,
        help=('A python list of strings that are passed as arguments for '
              'ffmpeg. Default: {}'.format(repr(DEFAULT_FFMPEG_VIDEO_ARGS))))
    parser.add_argument(
        '--fps', type=int, default=60,
        help=('Set framerate. Recommended values are 50, 60 and anything '
              'higher that is supported by the display and streaming '
              'technology.'))
    parser.add_argument(
        '--fullscreen', '-f', action='store_true',
        help='Enable fullscreen mode for uadescope')
    parser.add_argument(
        '--image-format', default='png', choices=['png', 'raw'],
        help='Generate intermediate image files in the given format')
    parser.add_argument(
        '--multiprocessing', action='store_true',
        help='Encode videos in parallel with all threads available.')
    parser.add_argument('--no-antialiasing', action='store_true',
                        help='Disable antialiasing')
    parser.add_argument(
        '--line-width',
        help=('Set line width for drawing oscilloscope waveforms. '
              'This is only effective if antialiasing is used. '
              'The default is 2 pixels on 720p resolution. '
              'The width is scaled accordingly by the resolution height.'))
    parser.add_argument(
        '--no-overwrite', '-n', action='store_true',
        help='If a video file already exists for the song, skip the song.')
    parser.add_argument(
        '--no-video', action='store_true',
        help=('Do not generate a video. This is useful when '
              '--encode-audio is used.'))
    parser.add_argument(
        '--panning', type=float, default=0.7,
        help='Set panning value. man uade123 for more information.')
    parser.add_argument(
        '--parallelism', '-p', type=int,
        help=('Sets the amount of parallelism encoded. '
              'Same as --multiprocessing but specifies the amount of '
              'parallelism explicitly.'))
    parser.add_argument(
        '--random-order', '-z', action='store_true',
        help='Process song files in random order')
    parser.add_argument(
        '--recursive', '-r', action='store_true',
        help='Scan directories recursively')
    parser.add_argument(
        '--resolution', default='1280x720',
        help=('Set resolution in format WxH, e.g. 1280x720. You can also give '
              'values 720p and 1080p.'))
    parser.add_argument(
        '--live', action='store_true',
        help='Visualize the oscilloscope video in real-time on screen')
    parser.add_argument(
        '--target-dir', '-t',
        help='This directory is needed if a video, csv file or audio is saved')
    parser.add_argument('--uade123', default='uade123', help='Path to uade123')
    parser.add_argument(
        '--uade123-args', type=ast.literal_eval, default={},
        help=('Pass given argument to uade123. This is written as a Python '
              'dictionary. E.g. passing -t 60 for uade123 means giving '
              'argument --uade123-args "{\'-t\': 60, \'-1\': None}". '
              'If dictionary '
              'value is None, the argument is interpreted to have no value. '
              'Values are automatically converted into strings. '
              'Note: Python dictionary '
              'preserves the order of dictionary entries, so the order of '
              'arguments is also preserved for uade123. '
              'Note: Giving --uade123-args "{\'-t\': 1}" is good for '
              'testing.'))
    parser.add_argument(
        '--write-audio-file', action='store_true',
        help='If this is set, a register file is written into the base dir')

    args = parser.parse_args()
    assert args.fps > 0

    _check_aa_factor(args.aa_factor)
    _parse_resolution(args.resolution)  # May raise ArgumentError

    live |= args.live

    if not live:
        if args.target_dir is None:
            raise ArgumentError('--target-dir/-t must be given')

    if not isinstance(args.ffmpeg_video_args, (list, tuple)):
        raise ArgumentError('ffmpeg_video_args must be a list or tuple of '
                            'strings')
    for ffmpeg_video_arg in args.ffmpeg_video_args:
        if not isinstance(ffmpeg_video_arg, str):
            raise ArgumentError('ffmpeg_video_arg must be a string: {}'.format(
                ffmpeg_video_arg))

    if args.accelerator is None:
        from . import uade_config
        args.accelerator = uade_config.WRITE_AUDIO_ACCELERATOR

    if args.target_dir is not None and not os.path.isdir(args.target_dir):
        raise ArgumentError('{} is not a directory'.format(args.target_dir))

    uade123_arg_list = []
    for key, value in args.uade123_args.items():
        if not isinstance(key, str):
            raise ArgumentError('Given key {} should be a string'.format(key))

        if value is None:
            uade123_arg_list.append(key)
        else:
            uade123_arg_list.extend((key, str(value)))

    if args.parallelism is not None:
        if args.parallelism < 1:
            raise ArgumentError('Invalid parallelism: {}'.format(
                args.parallelism))
        num_processes = args.parallelism
    elif args.multiprocessing:
        num_processes = cpu_count()
    else:
        num_processes = 1

    write_audio_options_list = [
        '--accelerator', args.accelerator,
        '--color-mode', str(args.color_mode),
        '--panning', str(args.panning),
        '--image-format', str(args.image_format),
    ]

    if args.color_seed is not None:
        write_audio_options_list.extend(('--color-seed', str(args.color_seed)))

    if num_processes > 1:
        write_audio_options_list.append('--batch')

    jobs = []
    for path in args.files:
        if os.path.isdir(path):
            if args.recursive:
                for dirpath, dirnames, filenames in os.walk(path):
                    for filename in filenames:
                        songfile = os.path.join(dirpath, filename)
                        jobs.append((songfile, args, uade123_arg_list,
                                     write_audio_options_list))
            else:
                print('Ignoring {} because it is a directory. Use -r to scan '
                      'directories.'.format(path))
                continue
        else:
            jobs.append((path, args, uade123_arg_list,
                         write_audio_options_list))

    if args.random_order:
        random.shuffle(jobs)

    if live:
        global default_sigint_handler
        default_sigint_handler = signal.signal(signal.SIGINT, sigint_handler)

        for job in jobs:
            ret = _live(*job)
            if ret == 0:
                continue
            if ret == UADE_RET_QUIT:
                # quit
                return 0
            return ret
    else:
        job_retcodes = []

        with Pool(processes=num_processes) as pool:
            try:
                ret_codes = pool.starmap(_generate_video, jobs)
                job_retcodes.extend(ret_codes)
            except KeyboardInterrupt:
                print('Keyboard interrupt raised..')
                # TODO: sleep() is a workaround that does not really fix the
                # problem that tmp directories are not deleted when CTRL-C is
                # pressed.
                time.sleep(1 + 0.1 * num_processes)
                raise

        for job_retcode in job_retcodes:
            if job_retcode != 0:
                return job_retcode

    return 0
