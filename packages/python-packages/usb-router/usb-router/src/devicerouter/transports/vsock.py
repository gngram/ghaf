import socket, time, threading
from typing import Callable, Dict, Any, Optional
from devicerouter.protocol import jsonl_reader, jsonl_send

AF_VSOCK = getattr(socket, "AF_VSOCK", None)
SOCK_STREAM = socket.SOCK_STREAM


class VsockServer(threading.Thread):
    """Server: listens for a vsock connection, receives messages."""
    def __init__(self, on_message: Callable[[Dict[str, Any]], None],
                 on_connect: Callable[[], None],
                 on_disconnect: Callable[[], None],
                 client_cid: int,
                 client_port: int,
                 with_ack = False):
        super().__init__(daemon=True)
        self.on_message = on_message
        self.on_connect = on_connect
        self.on_disconnect = on_disconnect
        self.client_port = client_port
        self.client_cid = client_cid
        self.sock: Optional[socket.socket] = None
        self.client: Optional[socket.socket] = None
        self.stop_flag = threading.Event()
        self.with_ack = with_ack

    def run(self):
        try:
            self.sock = socket.socket(AF_VSOCK, SOCK_STREAM)
            self.sock.bind((self.client_cid, self.client_port))
            self.sock.listen(1)
            print ("Socket successfully created")
        except socket.error as err:
             raise SystemError(f"VSOCK server setup failed: {err}") from err

        while not self.stop_flag.is_set():
            try:
                self.client, _ = self.sock.accept()
                self.on_connect()
                for msg in jsonl_reader(self.client):
                    self.on_message(msg)
                if self.with_ack:
                    jsonl_send(self.client, {"type": "ack", "status": "ok"})

            except socket.error as err:
                try: self.client.close()
                except: pass
                continue
            finally:
                if self.client:
                    try: self.client.close()
                    except: pass
                    self.client = None
                    self.on_disconnect()

    def stop(self):
        self.stop_flag.set()
        try:
            if self.client: self.client.close()
        except: pass
        try:
            if self.sock: self.sock.close()
        except: pass

class VsockClient():
    """Client: Sends message to server."""
    def __init__(self, port: int, cid: int):
        self.port = port
        self.cid = cid

    def send(self, data: Dict[str, Any], get_ack = False):
        while True:
            try:
                sock = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM)
                sock.connect((self.cid, self.port))
                jsonl_send(sock, data)
                if get_ack:
                    ack_received = False
                    for ack in jsonl_reader(sock):
                        if ack.get("type") == "ack":
                            ack_received = True
                            print(f"[DeviceRouter] ACK: {ack.get("status")}")
                            break
                    if ack_received == False:
                        print(f"[DeviceRouter] Warning! No ack received!")

                sock.close()
                break
            except Exception:
                print(f"[DeviceRouter] Vsock server error: {e}")
                time.sleep(2.0)
                continue
