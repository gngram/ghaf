import socket
import os
import json
import tempfile
import threading
from pathlib import Path
from typing import Dict, Any

from devicerouter.transports.vsock import VsockServer

class RegistryService:
    def __init__(self, port: int, regDir: str = "/run/usb-router"):
        # Determine our own CID first
        with socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM) as s:
            self.cid, _ = s.getsockname()

        self.server = VsockServer(
            on_message=self.on_msg,
            on_connect=self.on_connect,
            on_disconnect=self.on_disconnect,
            server_cid=self.cid,
            server_port=port,
        )

        self.connected = False
        self.regpath = Path(regDir)
        self.regpath.mkdir(parents=True, exist_ok=True)

        self.regFile = self.regpath / "usb-devices.json"
        if not self.regFile.exists():
            self.regFile.write_text("{}", encoding="utf-8")

        self._lock = threading.Lock()

    def start(self):
        self.server.start()

    def stop(self):
        self.server.stop()

    def wait(self):
        self.server.join()

    def on_connect(self):
        self.connected = True
        print("[devicerouter] Connected to Host")

    def on_disconnect(self):
        if self.connected:
            print("[devicerouter] Host Disconnected;")
        self.connected = False

    # ===== Helpers for registry IO =====
    def _read_registry(self) -> Dict[str, Any]:
        try:
            text = self.regFile.read_text(encoding="utf-8")
            return json.loads(text or "{}")
        except Exception as e:
            print(f"[devicerouter] Failed to read registry: {e}; resetting to empty")
            return {}

    def _write_registry(self, data: Dict[str, Any]) -> None:
        try:
            # Atomic write: write to tmp then replace
            with tempfile.NamedTemporaryFile("w", delete=False, dir=self.regpath, encoding="utf-8") as tf:
                json.dump(data, tf, indent=2, ensure_ascii=False)
                tmp_name = tf.name
            os.replace(tmp_name, self.regFile)  # atomic on POSIX
        except Exception as e:
            print(f"[devicerouter] Failed to write registry: {e}")

    
    def on_msg(self, msg: Dict[str, Any]):
        msgtype = msg.get("type")

        if msgtype == "device_connected":
            device = msg.get("device") or {}
            device_id = device.get("device_id")
            if not device_id:
                print("[devicerouter] device_connected: missing device_id")
                return

            entry = {
                "vendor": device.get("vendor") or "",
                "product": device.get("product") or "",
                "permitted_vms": list(device.get("permitted_vms") or []),
                "current-vm": msg.get("current-vm") or "",
            }

            with self._lock:
                reg = self._read_registry()
                reg[device_id] = entry
                self._write_registry(reg)

            print(f"[devicerouter] device_connected: {device_id} -> {entry['current-vm']}")

        elif msgtype == "device_removed":
            device_id = msg.get("device_id")
            if not device_id:
                print("[devicerouter] device_removed: missing device_id")
                return

            with self._lock:
                reg = self._read_registry()
                if device_id in reg:
                    del reg[device_id]
                    self._write_registry(reg)
                    print(f"[devicerouter] device_removed: {device_id} removed")
                else:
                    print(f"[devicerouter] device_removed: {device_id} not found")

        else:
            print(f"[devicerouter] unknown msg: {msg}")
