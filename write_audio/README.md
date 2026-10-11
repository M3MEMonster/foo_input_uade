# Oscilloscope view

generate_oscilloscope_view.py is a Python script to generate Oscilloscope
view videos with FFMPEG. Usage:
```
$ python3 generate_oscilloscope_view.py --target-dir /video_dir ../songs/AHX.Cruisin
```

A generated video is 720p @ 60 frames per second by default.

# Dependencies

C++ libraries:

* libSDL2 (apt install libsdl2-dev)

Tools:
* ffmpeg (apt install ffmpeg)

Python 3 libraries:
* Python Imaging Library (apt install python3-pil)
* tqdm (apt install python3-tqdm)

# Limitations

Produces only 720p videos.
