import time
import socket
from typing import Dict, Any, Optional


from devicerouter.transports.vsock import VsockServer

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
        print("[HOST] Connected to controller VM")

    def on_disconnect(self):
        if self.connected:
            print("[HOST] Controller VM Disconnected;")
        self.connected = False

    def on_msg(self, msg: Dict[str, Any]):
        msgtype = msg.get("type")
        if msgtype == "selection":
            device_id = msg.get("device_id")
            target_vm = msg.get("target_vm")
            print(f"[HOST devicerouter] {msgtype} {device_id} -> {target_vm}")
        else:
            print(f"[HOST] unknown msg: {msg}")

