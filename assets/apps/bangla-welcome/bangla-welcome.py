#!/usr/bin/env python3
"""Bangla OS first-run welcome dialog (GTK3)."""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

try:
    import gi

    gi.require_version("Gtk", "3.0")
    from gi.repository import GdkPixbuf, Gtk
except ImportError:
    sys.exit(0)

CONFIG_DIR = Path.home() / ".config" / "bangla-os"
DISMISS_FILE = CONFIG_DIR / "welcome-dismissed"
APP_ID = "bangla-welcome"
LOGO_PATH = Path("/usr/share/icons/hicolor/128x128/apps/bangla-os.png")


def read_pretty_name() -> str:
    for path in (Path("/etc/os-release"), Path("/usr/lib/os-release")):
        if not path.is_file():
            continue
        for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
            if line.startswith("PRETTY_NAME="):
                return line.split("=", 1)[1].strip().strip('"')
    return "Bangla OS"


def dismissed() -> bool:
    return DISMISS_FILE.is_file()


def set_dismissed() -> None:
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    DISMISS_FILE.write_text("1\n", encoding="utf-8")


def run_command(argv: list[str]) -> None:
    try:
        subprocess.Popen(argv, start_new_session=True)
    except OSError:
        pass


class WelcomeApp(Gtk.Application):
    def __init__(self) -> None:
        super().__init__(application_id=APP_ID)

    def do_activate(self) -> None:
        if dismissed():
            self.quit()
            return
        self.window = WelcomeWindow(self)
        self.window.show_all()


class WelcomeWindow(Gtk.ApplicationWindow):
    def __init__(self, app: Gtk.Application) -> None:
        super().__init__(application=app, title="Bangla OS", default_width=560, default_height=420)
        self.set_border_width(16)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.connect("destroy", lambda *_: self.get_application().quit())

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        self.add(root)

        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        root.pack_start(header, False, False, 0)

        if LOGO_PATH.is_file():
            img = Gtk.Image.new_from_pixbuf(
                GdkPixbuf.Pixbuf.new_from_file_at_scale(str(LOGO_PATH), 64, 64, True)
            )
            header.pack_start(img, False, False, 0)

        title_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        title_box.pack_start(
            Gtk.Label(label="<big><b>বাঙলা OS তে স্বাগতম</b></big>", use_markup=True, xalign=0),
            False,
            False,
            0,
        )
        title_box.pack_start(
            Gtk.Label(label=f"Welcome to {read_pretty_name()}", xalign=0),
            False,
            False,
            0,
        )
        header.pack_start(title_box, True, True, 0)

        root.pack_start(
            Gtk.Label(
                label="দ্রুত সেটআপ বেছে নিন / Choose a quick setup task:",
                xalign=0,
            ),
            False,
            False,
            0,
        )

        grid = Gtk.Grid(column_spacing=8, row_spacing=8)
        root.pack_start(grid, True, True, 0)

        actions = [
            ("🌐  নেটওয়ার্ক / Network", self._open_network),
            ("⌨  বাংলা কীবোর্ড / Bengali keyboard", self._open_keyboard),
            ("📦  সফটওয়্যার / Software", self._open_software),
            ("🍷  Wine (Windows apps)", self._open_wine_help),
        ]
        for i, (label, handler) in enumerate(actions):
            btn = Gtk.Button(label=label)
            btn.connect("clicked", handler)
            btn.set_halign(Gtk.Align.FILL)
            grid.attach(btn, 0, i, 1, 1)

        self.dismiss_cb = Gtk.CheckButton(label="আবার দেখাবেন না / Don't show again")
        root.pack_start(self.dismiss_cb, False, False, 0)

        footer = Gtk.Box(spacing=8)
        root.pack_start(footer, False, False, 0)
        footer.pack_end(Gtk.Button(label="Close", relief=Gtk.ReliefStyle.NONE, clicked=self._close), False, False, 0)

    def _open_network(self, _btn: Gtk.Button) -> None:
        for cmd in (["nm-connection-editor"], ["xfce4-settings-manager"], ["mousepad"]):
            if shutil_which(cmd[0]):
                run_command(cmd)
                return

    def _open_keyboard(self, _btn: Gtk.Button) -> None:
        for cmd in (["ibus-setup"], ["im-config"], ["xfce4-keyboard-settings"]):
            if shutil_which(cmd[0]):
                run_command(cmd)
                return

    def _open_software(self, _btn: Gtk.Button) -> None:
        for cmd in (["xfce4-appfinder"], ["firefox-esr"], ["mousepad"]):
            if shutil_which(cmd[0]):
                run_command(cmd)
                return

    def _open_wine_help(self, _btn: Gtk.Button) -> None:
        script = (
            "echo 'Wine on Bangla OS'; wine --version 2>/dev/null || echo 'Wine not found'; "
            "echo; echo 'Tip: Menu → Wine, or: apt install wine'; read -p 'Press Enter...'"
        )
        for term in ("xfce4-terminal", "x-terminal-emulator"):
            if shutil_which(term):
                run_command([term, "-e", "bash", "-lc", script])
                return

    def _close(self, _btn: Gtk.Button) -> None:
        if self.dismiss_cb.get_active():
            set_dismissed()
        self.get_application().quit()


def shutil_which(name: str) -> str | None:
    for path in os.environ.get("PATH", "").split(os.pathsep):
        candidate = Path(path) / name
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate)
    return None


def main() -> int:
    if dismissed() and "--force" not in sys.argv:
        return 0
    app = WelcomeApp()
    return app.run(sys.argv)


if __name__ == "__main__":
    raise SystemExit(main())
