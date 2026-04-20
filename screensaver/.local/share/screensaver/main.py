import os
import random
from dataclasses import dataclass
import pyglet
from pyglet.gl import GL_NEAREST
from pyglet.image import Texture

Texture.default_mag_filter = Texture.default_min_filter = GL_NEAREST

@dataclass
class Monitor:
    win: pyglet.window.Window
    sprite: pyglet.sprite.Sprite
    vx: float
    vy: float

image = pyglet.image.load(os.path.expanduser('~/.local/share/assets/artix-logo.png'))

monitors = []
for screen in pyglet.display.get_display().get_screens():
    win = pyglet.window.Window(
        width=screen.width, height=screen.height,
        style=pyglet.window.Window.WINDOW_STYLE_BORDERLESS,
        caption='screensaver',
        vsync=False,
    )
    win.set_location(screen.x, screen.y)
    sprite = pyglet.sprite.Sprite(img=image)
    sprite.x = random.uniform(0, screen.width - image.width)
    sprite.y = random.uniform(0, screen.height - image.height)
    monitors.append(Monitor(
        win=win,
        sprite=sprite,
        vx=random.choice([-1, 1]) * random.uniform(150, 300),
        vy=random.choice([-1, 1]) * random.uniform(150, 300),
    ))

for m in monitors:
    @m.win.event
    def on_draw(win=m.win, sprite=m.sprite):
        win.clear()
        sprite.draw()

    @m.win.event
    def on_mouse_press(x, y, button, modifiers):
        pyglet.app.exit()

    @m.win.event
    def on_key_press(symbol, modifier):
        pyglet.app.exit()


def update(dt):
    for m in monitors:
        m.sprite.x += m.vx * dt
        m.sprite.y += m.vy * dt
        if m.sprite.x <= 0 or m.sprite.x + image.width >= m.win.width:
            m.vx = -m.vx * random.uniform(0.9, 1.1)
            m.sprite.x = max(0, min(m.sprite.x, m.win.width - image.width))
        if m.sprite.y <= 0 or m.sprite.y + image.height >= m.win.height:
            m.vy = -m.vy * random.uniform(0.9, 1.1)
            m.sprite.y = max(0, min(m.sprite.y, m.win.height - image.height))


pyglet.clock.schedule_interval(update, 1/60)
pyglet.app.run()
