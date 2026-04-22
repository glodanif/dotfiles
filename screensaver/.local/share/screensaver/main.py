import os
import time
import random
import pyglet
from pyglet.gl import GL_NEAREST
from pyglet.image import Texture

Texture.default_mag_filter = Texture.default_min_filter = GL_NEAREST

START_TIME = time.time()
GRACE_PERIOD = 2.0

image = pyglet.image.load(os.path.expanduser('~/.local/share/assets/artix-logo.png'))

screen = pyglet.display.get_display().get_screens()[0]
win = pyglet.window.Window(
    width=screen.width, height=screen.height,
    caption='screensaver',
    vsync=False,
)
win.set_mouse_visible(False)

sprite = pyglet.sprite.Sprite(img=image)
sprite.x = random.uniform(0, screen.width - image.width)
sprite.y = random.uniform(0, screen.height - image.height)
vx = random.choice([-1, 1]) * random.uniform(150, 300)
vy = random.choice([-1, 1]) * random.uniform(150, 300)

@win.event
def on_draw():
    win.clear()
    sprite.draw()

@win.event
def on_key_press(symbol, modifier):
    if time.time() - START_TIME > GRACE_PERIOD:
        pyglet.app.exit()

@win.event
def on_mouse_press(x, y, button, modifiers):
    if time.time() - START_TIME > GRACE_PERIOD:
        pyglet.app.exit()

@win.event
def on_close():
    pyglet.app.exit()

def update(dt):
    global vx, vy
    sprite.x += vx * dt
    sprite.y += vy * dt
    if sprite.x <= 0 or sprite.x + image.width >= win.width:
        vx = -vx * random.uniform(0.9, 1.1)
        sprite.x = max(0, min(sprite.x, win.width - image.width))
    if sprite.y <= 0 or sprite.y + image.height >= win.height:
        vy = -vy * random.uniform(0.9, 1.1)
        sprite.y = max(0, min(sprite.y, win.height - image.height))

pyglet.clock.schedule_interval(update, 1/60)
pyglet.app.run()

