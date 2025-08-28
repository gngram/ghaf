# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

import socket
import os
import json
import tempfile
import threading
from pathlib import Path
from typing import Dict, Any

from usb_passthrough_manager.transports.vsock import VsockServer
import logging
logger = logging.getLogger("usb_passthrough_manager")

class RegistryService:
    def __init__(self, cid: int, port: int, regDir: str):
        self.server = VsockServer(
            on_message=self.on_msg,
            on_connect=self.on_connect,
            on_disconnect=self.on_disconnect,
            server_cid=cid,
            server_port=port,
        )

        self.connected = False
        self.regpath = Path(regDir)
        self.regpath.mkdir(parents=True, exist_ok=True)
        try:
            # Ensure directory is accessible by other users to read the registry file.
            os.chmod(self.regpath, 0o755)
        except OSError as e:
            logger.error(f"Failed to set permissions on registry directory {self.regpath}: {e}")

        self.regFile = self.regpath / "usb_db.json"
        if not self.regFile.exists():
            self.regFile.write_text("{}", encoding="utf-8")

        # Set permissions to be readable by all users.
        # This service runs as root, so we need to explicitly set permissions.
        try:
            os.chmod(self.regFile, 0o644)
        except OSError as e:
            logger.error(f"Failed to set permissions on registry file {self.regFile}: {e}")

        self._lock = threading.Lock()

    def start(self):
        self.server.start()

    def stop(self):
        self.server.stop()

    def wait(self):
        self.server.join()

    def on_connect(self):
        self.connected = True
        logger.info("Connected to Host")

    def on_disconnect(self):
        if self.connected:
            logger.info("Host Disconnected;")
        self.connected = False

    def _read_registry(self) -> Dict[str, Any]:
        try:
            text = self.regFile.read_text(encoding="utf-8")
            return json.loads(text or "{}")
        except Exception as e:
            logger.error(f"Failed to read registry: {e}; resetting to empty")
            return {}

    def _write_registry(self, data: Dict[str, Any]) -> None:
        try:
            # Atomic write: write to tmp then replace
            with tempfile.NamedTemporaryFile("w", delete=False, dir=self.regpath, encoding="utf-8") as tf:
                json.dump(data, tf, indent=2, ensure_ascii=False)
                tmp_name = tf.name
            os.replace(tmp_name, self.regFile)  # atomic on POSIX
            os.chmod(self.regFile, 0o644)
        except Exception as e:
            logger.error(f"Failed to write registry: {e}")


    def on_msg(self, msg: Dict[str, Any]):
        msgtype = msg.get("type")

        if msgtype == "device_connected":
            device = msg.get("device") or {}
            device_id = device.get("device_id")
            if not device_id:
                logger.error("Device_connected: missing device_id")
                return

            entry = {
                "vendor": device.get("vendor") or "",
                "product": device.get("product") or "",
                "permitted-vms": list(device.get("permitted-vms") or []),
                "current-vm": device.get("current-vm") or "",
            }

            with self._lock:
                reg = self._read_registry()
                reg[device_id] = entry
                self._write_registry(reg)

            logger.info(f"device_connected: {device_id} -> {entry['current-vm']}")

        elif msgtype == "device_removed":
            device_id = msg.get("device_id")
            if not device_id:
                logger.error("device_removed: missing device_id")
                return

            with self._lock:
                reg = self._read_registry()
                if device_id in reg:
                    del reg[device_id]
                    self._write_registry(reg)
                    logger.info(f"device_removed: {device_id} removed")
                else:
                    logger.error(f"device_removed: {device_id} not found")

        else:
            logger.error(f"unknown schema: {msg}")
