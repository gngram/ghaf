import time
from typing import Dict, Any, Optional

from devicerouter.transports.vsock import VsockServer

class HostService:
    def __init__(self, client_cid: int, client_port: int):
        self.server = VsockServer(on_message = self.on_msg,
                 on_connect = self.on_connect,
                 on_disconnect = self.on_disconnect,
                 client_cid = client_cid,
                 client_port = client_port)
        self.connected = False

    def start(self):
        self.server.start()

    def stop(self):
        self.server.stop()

    def on_connect(self):
        self.connected = True
        print("[HOST] Connected to GUI VM")

    def on_disconnect(self):
        if self.connected:
            print("[HOST] GUI VM Disconnected;")
        self.connected = False

    def on_msg(self, msg: Dict[str, Any]):
        msgtype = msg.get("type")
        if msgtype == "selection":
            device_id = msg.get("device_id")
            target_vm = msg.get("target_vm")
            print(f"[HOST devicerouter] {msgtype} {device_id} -> {target_vm}")
        else:
            print(f"[HOST] unknown msg: {msg}")
# - device_connected: {"type":"device_connected","device":{...},"current-vm":{...}}
# - selection: {"type":"selection","device_id":"vid:pid","target_vm":"..."}
# - device_removed: {"type":"device_removed","device_id":"vid:pid"}
