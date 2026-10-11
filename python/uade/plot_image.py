import random


COLORS = None
COLOR_MODES = tuple(range(4))


def init_colors(color_mode: int, color_seed: int | None):
    global COLORS

    old_state = random.getstate()
    if color_seed is None:
        color_seed = 0
    random.seed(color_seed)

    COLORS = {}
    if color_mode == 0:
        COLORS[0] = (255, 255, 255)
    elif color_mode == 1:
        for i in range(64):
            col = [255, 0, int(256 * random.random())]
            random.shuffle(col)
            COLORS[i] = tuple(col)
    elif color_mode == 2:
        for i in range(64):
            x = int(256 * random.random())
            col = [255, (x * 31) % 128, x]
            random.shuffle(col)
            COLORS[i] = tuple(col)
    elif color_mode == 3:
        for i in range(64):
            col = [0, 0, 0]
            while (col[0] + col[1]) < 64:
                col = [255, 0, int(256 * random.random())]
                random.shuffle(col)
            COLORS[i] = tuple(col)
    else:
        raise ValueError('Invalid color mode: {}'.format(color_mode))

    random.setstate(old_state)
