#!/usr/bin/env python3

import json
import socket
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton,
    QMessageBox, QScrollArea, QFrame, QComboBox
)

# Reuse the small helpers from widgets.py
from devicerouter.guest.widgets import device_title_html, SELECT_LABEL
from devicerouter.transports.vsock import VsockClient

def _read_schema_once(path: Path) -> Dict[str, Any]:
    """Read+close immediately. Returns {} on error."""
    try:
        print("GGGGGGGGGGGGGGGGG", path)
        with open(path, "r") as f:
            doc = json.load(f) or {}
    except Exception as e:
        print(f"[devicerouter GUI] Failed to read schema file: {e}", file=sys.stderr)
        return {}
    # normalize basic shape
    if not isinstance(doc, dict):
        return {}
    doc.setdefault("devices", {})
    doc.setdefault("current-mount", {})
    return doc

def _send_selection_vsock(device_id: str, selected_vm: str, host_port: int) -> None:
    """Ephemeral vsock client: connect → send JSONL → close."""
    cid_host = getattr(socket, "VMADDR_CID_HOST", 2)
    payload = {
        "type": "selection",
        "device_id": device_id,
        "current-vm": selected_vm,
    }
    host = VsockClient(host_port, cid_host)
    host.send(payload)

class App(QWidget):
    def __init__(self, file_path: Path, host_port: int,
                 combo_width: Optional[int] = 100, popup_width: Optional[int] = None):
        super().__init__()
        self.setWindowTitle("Device Router")
        self.resize(760, 560)

        self.file_path = file_path
        self.host_port = host_port
        self.combo_width = combo_width
        self.popup_width = popup_width

        # device_id -> {"container":QFrame, "label":QLabel, "combo":QComboBox}
        self.blocks: Dict[str, Dict[str, Any]] = {}

        # ---- Layout ----
        root = QVBoxLayout(self)

        self.scroll = QScrollArea()
        self.scroll.setWidgetResizable(True)
        self.inner = QWidget()
        self.devices_layout = QVBoxLayout(self.inner)
        self.devices_layout.setSpacing(12)
        self.devices_layout.addStretch(1)
        self.scroll.setWidget(self.inner)
        root.addWidget(self.scroll)

        # Bottom buttons
        btn_row = QHBoxLayout()
        btn_row.addStretch(1)
        self.refresh_btn = QPushButton("Refresh")
        self.refresh_btn.setToolTip("Re-read the JSON file and update the UI.")
        self.refresh_btn.clicked.connect(self.reload_from_file)
        self.close_btn = QPushButton("Close")
        self.close_btn.clicked.connect(self.close)
        btn_row.addWidget(self.refresh_btn)
        btn_row.addWidget(self.close_btn)
        root.addLayout(btn_row)

        # Initial load
        self.reload_from_file()

    # ---------- UI building ----------
    def _clear_blocks(self):
        for info in self.blocks.values():
            w = info.get("container")
            if w:
                w.setParent(None)
                w.deleteLater()
        self.blocks.clear()

    def _make_combo(self, device_id: str, items: List[str], selected: Optional[str]) -> QComboBox:
        combo = QComboBox()
        combo.setEditable(False)
        all_items = [SELECT_LABEL] + items
        combo.addItems(all_items)

        # width controls
        if self.combo_width:
            combo.setFixedWidth(self.combo_width)
        else:
            combo.setSizeAdjustPolicy(QComboBox.AdjustToContents)
            combo.setMinimumContentsLength(max((len(s) for s in all_items), default=8))

        if self.popup_width:
            combo.view().setMinimumWidth(self.popup_width)
        else:
            fm = combo.fontMetrics()
            longest_px = max((fm.horizontalAdvance(s) for s in all_items), default=80)
            combo.view().setMinimumWidth(longest_px + 60)

        idx = 0 if not selected or selected not in items else (items.index(selected) + 1)
        combo.setCurrentIndex(idx)
        combo.currentIndexChanged.connect(lambda _i, d=device_id: self.on_combo_changed(d))
        return combo

    def _add_block(self, device_id: str, vendor: str, product: str,
                   targets: List[str], selected: Optional[str]):
        container = QFrame()
        container.setFrameShape(QFrame.NoFrame)
        v = QVBoxLayout(container)
        v.setSpacing(6)

        lbl = QLabel()
        lbl.setTextFormat(Qt.RichText)
        lbl.setTextInteractionFlags(Qt.TextSelectableByMouse)
        lbl.setText(device_title_html(device_id, vendor, product))
        v.addWidget(lbl)

        combo = self._make_combo(device_id, targets, selected)
        v.addWidget(combo)

        self.devices_layout.insertWidget(self.devices_layout.count() - 1, container)
        self.blocks[device_id] = {"container": container, "label": lbl, "combo": combo}

    def reload_from_file(self):
        doc = _read_schema_once(self.file_path)
        devices = doc.get("devices", {}) or {}
        mounts = doc.get("current-mount", {}) or {}

        # Rebuild everything (simple & robust for shared file)
        self._clear_blocks()

        for dev_id, meta in devices.items():
            permitted = list(meta.get("permitted_vms", []))
            vendor = meta.get("Vendor") or ""
            product = meta.get("Product") or ""
            selected = mounts.get(dev_id)
            self._add_block(dev_id, vendor, product, permitted, selected)

    # ---------- events ----------
    def on_combo_changed(self, device_id: str):
        info = self.blocks.get(device_id)
        if not info:
            return
        combo: QComboBox = info["combo"]
        choice = combo.currentText()
        if choice == SELECT_LABEL:
            # do nothing on neutral selection
            return
        try:
            _send_selection_vsock(device_id, choice, self.host_port)
        except Exception as e:
            QMessageBox.critical(self, "Send error", f"Failed to send selection:\n{e}")
