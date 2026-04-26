#!/usr/bin/env python3
"""
Shutdown/reboot/logout overlay. Layer-shell overlay on all monitors.
Centered Artix logo with configurable text underneath.

Usage:
    python overlay.py "Shutting down..."
    python overlay.py "Rebooting..."
    python overlay.py "Logging out..."

Dependencies (Artix/Arch):
    pacman -S gtk4-layer-shell python-gobject gtk4 python-cairo

Place at: ~/.local/share/screensaver/overlay.py
Logo at:  ~/.local/share/assets/artix-logo.png
"""

import os
import sys

from ctypes import CDLL
CDLL('libgtk4-layer-shell.so')

import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Gtk4LayerShell', '1.0')
from gi.repository import Gtk, Gdk, GLib
from gi.repository import Gtk4LayerShell as LayerShell

LOGO_PATH = os.path.expanduser('~/.local/share/assets/artix-logo.png')
BG_COLOR = '#330066'
TEXT_COLOR = '#ffffff'
TEXT_SIZE_PT = 24
LOGO_MAX_HEIGHT = 128


class OverlayApp:
    def __init__(self, message):
        self.message = message
        self.app = Gtk.Application(application_id='com.overlay.power')
        self.app.connect('activate', self._on_activate)

    def _on_activate(self, app):
        texture = Gdk.Texture.new_from_filename(LOGO_PATH)

        css = Gtk.CssProvider()
        css.load_from_string(
            f'window {{ background-color: {BG_COLOR}; }}'
            f'label {{ color: {TEXT_COLOR}; font-size: {TEXT_SIZE_PT}pt; font-family: Lato; }}'
        )
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(), css,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

        display = Gdk.Display.get_default()
        monitors = display.get_monitors()
        for i in range(monitors.get_n_items()):
            monitor = monitors.get_item(i)
            self._create_window(app, monitor, texture)

    def _create_window(self, app, monitor, texture):
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
        LayerShell.set_namespace(window, 'power-overlay')

        window.set_cursor(Gdk.Cursor.new_from_name('none'))

        # Centered layout: logo + text
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=48)
        box.set_halign(Gtk.Align.CENTER)
        box.set_valign(Gtk.Align.CENTER)

        picture = Gtk.Picture.new_for_paintable(texture)
        picture.set_content_fit(Gtk.ContentFit.CONTAIN)
        picture.set_size_request(LOGO_MAX_HEIGHT, LOGO_MAX_HEIGHT)
        box.append(picture)

        label = Gtk.Label(label=self.message)
        box.append(label)

        window.set_child(box)
        window.present()

    def run(self):
        self.app.run(None)


if __name__ == '__main__':
    message = sys.argv[1] if len(sys.argv) > 1 else 'Shutting down...'
    OverlayApp(message).run()

