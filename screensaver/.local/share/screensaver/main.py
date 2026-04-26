#!/usr/bin/env python3
"""
Bouncing logo screensaver using GTK4 + gtk4-layer-shell.
One overlay window per monitor. Wayland layer-shell, no compositor fights.

Dependencies (Artix/Arch):
    pacman -S gtk4-layer-shell python-gobject gtk4 python-cairo

Place at: ~/.local/share/screensaver/main.py
Logo at:  ~/.local/share/assets/artix-logo.png
"""

import os
import random
import time

from ctypes import CDLL
CDLL('libgtk4-layer-shell.so')

import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Gtk4LayerShell', '1.0')
from gi.repository import Gtk, Gdk, GdkPixbuf
from gi.repository import Gtk4LayerShell as LayerShell

LOGO_PATH = os.path.expanduser('~/.local/share/assets/artix-logo.png')
GRACE_PERIOD = 2.0
MAX_SPEED = 400


class BouncingLogo:
    def __init__(self, width, height, logo_w, logo_h):
        self.area_w = width
        self.area_h = height
        self.logo_w = logo_w
        self.logo_h = logo_h

        self.x = random.uniform(0, max(1, width - logo_w))
        self.y = random.uniform(0, max(1, height - logo_h))
        self.vx = random.choice([-1, 1]) * random.uniform(150, 300)
        self.vy = random.choice([-1, 1]) * random.uniform(150, 300)

    def update(self, dt):
        self.x += self.vx * dt
        self.y += self.vy * dt

        if self.x <= 0 or self.x + self.logo_w >= self.area_w:
            self.vx = -self.vx * random.uniform(0.9, 1.1)
            self.x = max(0, min(self.x, self.area_w - self.logo_w))

        if self.y <= 0 or self.y + self.logo_h >= self.area_h:
            self.vy = -self.vy * random.uniform(0.9, 1.1)
            self.y = max(0, min(self.y, self.area_h - self.logo_h))

        self.vx = max(-MAX_SPEED, min(MAX_SPEED, self.vx))
        self.vy = max(-MAX_SPEED, min(MAX_SPEED, self.vy))


class MonitorOverlay:
    """One fullscreen overlay on a single monitor."""

    def __init__(self, app, monitor, texture, logo_w, logo_h, quit_cb):
        self.quit_cb = quit_cb

        geom = monitor.get_geometry()
        scale = monitor.get_scale_factor()
        width = geom.width
        height = geom.height

        self.logo = BouncingLogo(width, height, logo_w, logo_h)

        window = Gtk.Window(application=app)

        LayerShell.init_for_window(window)
        LayerShell.set_layer(window, LayerShell.Layer.OVERLAY)
        LayerShell.set_monitor(window, monitor)
        LayerShell.set_anchor(window, LayerShell.Edge.TOP, True)
        LayerShell.set_anchor(window, LayerShell.Edge.BOTTOM, True)
        LayerShell.set_anchor(window, LayerShell.Edge.LEFT, True)
        LayerShell.set_anchor(window, LayerShell.Edge.RIGHT, True)
        LayerShell.set_exclusive_zone(window, -1)
        LayerShell.set_keyboard_mode(window, LayerShell.KeyboardMode.ON_DEMAND)
        LayerShell.set_namespace(window, 'screensaver')

        self.fixed = Gtk.Fixed()
        self.picture = Gtk.Picture.new_for_paintable(texture)
        self.picture.set_size_request(logo_w, logo_h)
        self.fixed.put(self.picture, self.logo.x, self.logo.y)
        window.set_child(self.fixed)

        # Input
        key_ctrl = Gtk.EventControllerKey()
        key_ctrl.connect('key-pressed', self._on_input)
        window.add_controller(key_ctrl)

        click_ctrl = Gtk.GestureClick()
        click_ctrl.connect('pressed', self._on_input)
        window.add_controller(click_ctrl)

        motion_ctrl = Gtk.EventControllerMotion()
        motion_ctrl.connect('motion', self._on_motion)
        window.add_controller(motion_ctrl)
        self._initial_mouse_pos = None

        window.set_cursor(Gdk.Cursor.new_from_name('none'))
        window.present()
        self.window = window

        self.last_frame = None
        self.fixed.add_tick_callback(self._tick)

    def _tick(self, widget, frame_clock):
        now = frame_clock.get_frame_time() / 1_000_000
        if self.last_frame is None:
            self.last_frame = now
            return True
        dt = now - self.last_frame
        self.last_frame = now

        self.logo.update(dt)
        self.fixed.move(self.picture, self.logo.x, self.logo.y)

        return True

    def _on_input(self, *args):
        self.quit_cb()

    def _on_motion(self, ctrl, x, y):
        if self._initial_mouse_pos is None:
            self._initial_mouse_pos = (x, y)
            return
        dx = abs(x - self._initial_mouse_pos[0])
        dy = abs(y - self._initial_mouse_pos[1])
        if dx > 10 or dy > 10:
            self.quit_cb()


class ScreensaverApp:
    def __init__(self):
        self.app = Gtk.Application(application_id='com.screensaver.bouncing-logo')
        self.app.connect('activate', self._on_activate)
        self.start_time = time.monotonic()
        self.overlays = []

    def _on_activate(self, app):
        pixbuf = GdkPixbuf.Pixbuf.new_from_file(LOGO_PATH)
        texture = Gdk.Texture.new_for_pixbuf(pixbuf)
        logo_w = pixbuf.get_width()
        logo_h = pixbuf.get_height()

        # Black background for all windows
        css = Gtk.CssProvider()
        css.load_from_string('window { background-color: black; }')
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(), css,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

        # One overlay per monitor
        display = Gdk.Display.get_default()
        monitors = display.get_monitors()
        for i in range(monitors.get_n_items()):
            monitor = monitors.get_item(i)
            overlay = MonitorOverlay(
                app, monitor, texture, logo_w, logo_h, self._quit,
            )
            self.overlays.append(overlay)

        # Give the first window keyboard focus
        if self.overlays:
            first = self.overlays[0]
            LayerShell.set_keyboard_mode(
                first.window, LayerShell.KeyboardMode.EXCLUSIVE,
            )

    def _quit(self):
        if (time.monotonic() - self.start_time) >= GRACE_PERIOD:
            self.app.quit()

    def run(self):
        self.app.run(None)


if __name__ == '__main__':
    ScreensaverApp().run()

