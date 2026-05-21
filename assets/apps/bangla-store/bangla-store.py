#!/usr/bin/env python3
"""Bangla Store — curated software installer (apt backend)."""
from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

try:
    import gi

    gi.require_version("Gtk", "3.0")
    from gi.repository import Gtk
except ImportError:
    sys.exit(0)

CATALOG = Path("/usr/share/bangla-os/bangla-store/software.json")
FALLBACK = Path(__file__).resolve().parent / "software.json"


def load_catalog() -> dict:
    for path in (CATALOG, FALLBACK):
        if path.is_file():
            return json.loads(path.read_text(encoding="utf-8"))
    return {"title_bn": "বাঙলা স্টোর", "title_en": "Bangla Store", "categories": []}


def pkg_installed(pkg: str) -> bool:
    try:
        r = subprocess.run(
            ["dpkg-query", "-W", "-f=${Status}", pkg],
            capture_output=True,
            text=True,
            timeout=10,
        )
        return "install ok installed" in (r.stdout or "")
    except (OSError, subprocess.TimeoutExpired):
        return False


def install_pkg(pkg: str) -> None:
    script = f"sudo apt-get update && sudo apt-get install -y {pkg}; echo; read -p 'Enter to close...'"
    for term in ("xfce4-terminal", "x-terminal-emulator", "xterm"):
        if shutil_which(term):
            subprocess.Popen([term, "-e", "bash", "-lc", script], start_new_session=True)
            return
    subprocess.Popen(["x-terminal-emulator", "-e", f"bash -lc '{script}'"], start_new_session=True)


def shutil_which(name: str) -> str | None:
    for path in os.environ.get("PATH", "").split(os.pathsep):
        candidate = Path(path) / name
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate)
    return None


class StoreApp(Gtk.Application):
    def __init__(self) -> None:
        super().__init__(application_id="bangla-store")
        self.catalog = load_catalog()

    def do_activate(self) -> None:
        self.window = StoreWindow(self)
        self.window.show_all()


class StoreWindow(Gtk.ApplicationWindow):
    def __init__(self, app: StoreApp) -> None:
        title = f"{app.catalog.get('title_bn', 'Bangla Store')} / {app.catalog.get('title_en', 'Bangla Store')}"
        super().__init__(application=app, title=title, default_width=720, default_height=480)
        self.catalog = app.catalog
        self.set_border_width(8)

        paned = Gtk.Paned(orientation=Gtk.Orientation.HORIZONTAL)
        self.add(paned)

        self.cat_store = Gtk.ListStore(str, str, str)  # id, label, json idx
        cat_view = Gtk.TreeView(model=self.cat_store)
        cat_view.append_column(Gtk.TreeViewColumn("Category", Gtk.CellRendererText(), text=1))
        cat_scroll = Gtk.ScrolledWindow()
        cat_scroll.add(cat_view)
        cat_scroll.set_size_request(200, -1)
        paned.add1(cat_scroll)

        self.app_store = Gtk.ListStore(str, str, str, str, bool)  # pkg, name, desc, status, installed
        self.app_view = Gtk.TreeView(model=self.app_store)
        for i, title in enumerate(("Software", "Description", "Status")):
            self.app_view.append_column(Gtk.TreeViewColumn(title, Gtk.CellRendererText(), text=i + 1))
        app_scroll = Gtk.ScrolledWindow()
        app_scroll.add(self.app_view)
        paned.add2(app_scroll)

        btn_row = Gtk.Box(spacing=8)
        install_btn = Gtk.Button(label="Install selected / ইনস্টল")
        install_btn.connect("clicked", self._on_install)
        refresh_btn = Gtk.Button(label="Refresh / রিফ্রেশ")
        refresh_btn.connect("clicked", lambda *_: self._refresh_apps())
        btn_row.pack_end(refresh_btn, False, False, 0)
        btn_row.pack_end(install_btn, False, False, 0)

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        self.remove(paned)
        root.pack_start(paned, True, True, 0)
        root.pack_start(btn_row, False, False, 0)
        self.add(root)

        self._cat_idx: dict[str, int] = {}
        for idx, cat in enumerate(self.catalog.get("categories", [])):
            label = f"{cat.get('name_bn', '')} / {cat.get('name_en', '')}"
            self.cat_store.append([cat.get("id", ""), label, str(idx)])
            self._cat_idx[cat["id"]] = idx

        cat_sel = cat_view.get_selection()
        cat_sel.connect("changed", self._on_category_changed)
        if self.cat_store.get_iter_first():
            cat_sel.select_path(Gtk.TreePath("0"))

    def _on_category_changed(self, selection: Gtk.TreeSelection) -> None:
        _model, tree_iter = selection.get_selected()
        if not tree_iter:
            return
        idx = int(_model[tree_iter][2])
        cat = self.catalog["categories"][idx]
        self._fill_apps(cat)

    def _fill_apps(self, cat: dict) -> None:
        self.app_store.clear()
        for app in cat.get("apps", []):
            pkg = app.get("pkg", "")
            name = f"{app.get('name_bn', pkg)} / {app.get('name_en', pkg)}"
            desc = f"{app.get('desc_bn', '')} — {app.get('desc_en', '')}"
            installed = pkg_installed(pkg)
            status = "Installed / ইনস্টল করা" if installed else "Not installed"
            self.app_store.append([pkg, name, desc, status, installed])

    def _on_install(self, _btn: Gtk.Button) -> None:
        selection = self.app_view.get_selection()
        model, tree_iter = selection.get_selected()
        if not tree_iter:
            return
        pkg = model[tree_iter][0]
        if model[tree_iter][4]:
            dlg = Gtk.MessageDialog(
                transient_for=self,
                flags=0,
                message_type=Gtk.MessageType.INFO,
                buttons=Gtk.ButtonsType.OK,
                text=f"{pkg} is already installed.",
            )
            dlg.run()
            dlg.destroy()
            return
        install_pkg(pkg)

    def _refresh_apps(self) -> None:
        for row in self.app_store:
            inst = pkg_installed(row[0])
            row[3] = "Installed / ইনস্টল করা" if inst else "Not installed"
            row[4] = inst


def main() -> int:
    return StoreApp().run(sys.argv)


if __name__ == "__main__":
    raise SystemExit(main())
