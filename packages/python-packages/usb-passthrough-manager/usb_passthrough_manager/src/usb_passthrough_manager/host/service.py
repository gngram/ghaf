# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

import time
import socket
from typing import Dict, Any, Optional

from usb_passthrough_manager.transports.vsock import VsockServer
import logging

logger = logging.getLogger("usb_passthrough_manager")

class HostService:
    def __init__(self, port: int):
        self.server = VsockServer(on_message = self.on_msg,
                 on_connect = self.on_connect,
                 on_disconnect = self.on_disconnect,
                 server_cid = socket.VMADDR_CID_HOST,
                 server_port = port)
        self.connected = False

    def start(self):
        self.server.start()

    def stop(self):
        self.server.stop()

    def wait(self):
        self.server.join()

    def on_connect(self):
        self.connected = True
        logger.info("Connected to controller VM")

    def on_disconnect(self):
        if self.connected:
            logger.info("Controller VM Disconnected;")
        self.connected = False

    def on_msg(self, msg: Dict[str, Any]):
        msgtype = msg.get("type")
        if msgtype == "selection":
            device_id = msg.get("device_id")
            target_vm = msg.get("current-vm")
            logger.info(f"{msgtype} {device_id} -> {target_vm}")
        else:
            logger.error(f"Unknown msg: {msg}")
