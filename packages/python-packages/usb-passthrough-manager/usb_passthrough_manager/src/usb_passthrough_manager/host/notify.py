# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

from typing import Dict, Any
import logging

logger = logging.getLogger("usb_passthrough_manager")

from usb_passthrough_manager.transports.vsock import VsockClient

class NotifyClient:
    def __init__(self, client_cid: int, client_port: int):
        self.client = VsockClient(
                 cid = client_cid,
                 port = client_port)

    def send(self, msg: Dict[str, Any]):
        msgtype = msg.get("type")
        if msgtype == "device_connected" or msgtype == "device_removed":
            logger.info(f"Sending schema {msgtype} {msg}")
            self.client.send(msg)
        else:
            logger.error(f"Sending schema, unknown msg: {msg}, ignored!")
