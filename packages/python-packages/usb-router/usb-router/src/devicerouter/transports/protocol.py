import json
import socket
from typing import Dict, Any, Generator

def jsonl_send(sock: socket.socket, obj: Dict[str, Any]) -> None:
    data = (json.dumps(obj, separators=(",", ":")) + "\n").encode("utf-8")
    sock.sendall(data)

def jsonl_reader(sock: socket.socket) -> Generator[Dict[str, Any], None, None]:
    buf = b""
    while True:
        chunk = sock.recv(4096)
        if not chunk:
            break
        buf += chunk
        while b"\n" in buf:
            line, buf = buf.split(b"\n", 1)
            line = line.strip()
            if line:
                yield json.loads(line.decode("utf-8"))

