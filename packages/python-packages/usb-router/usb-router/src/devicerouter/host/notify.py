import time
from typing import Dict, Any, Optional

from devicerouter.transports.vsock import VsockClient

class NotifyClient:
    def __init__(self, client_cid: int, client_port: int):
        self.client = VsockClient(
                 cid = client_cid,
                 port = client_port)

    def send(self, msg: Dict[str, Any]):
        msgtype = msg.get("type")
        if msgtype == "device_connected" or msgtype == "device_removed":
            print(f"[HOST] {msgtype} {msg}")
            self.client.send(msg)
        else:
            print(f"[HOST] unknown msg: {msg}, ignored!")

# - device_connected: {"type":"device_connected","device":{...},"current-vm":{...}}
# - selection: {"type":"selection","device_id":"vid:pid","target_vm":"..."}
# - device_removed: {"type":"device_removed","device_id":"vid:pid"}
