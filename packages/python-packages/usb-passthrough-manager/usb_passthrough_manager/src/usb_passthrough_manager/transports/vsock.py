# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

import socket, time, threading
from typing import Callable, Dict, Any, Optional
from usb_passthrough_manager.transports.protocol import jsonl_reader, jsonl_send

import logging
logger = logging.getLogger("usb_passthrough_manager")

AF_VSOCK = getattr(socket, "AF_VSOCK", None)
SOCK_STREAM = socket.SOCK_STREAM


class VsockServer(threading.Thread):
    """Guest VM Server: listens for a vsock connection, receives messages."""
    def __init__(self, on_message: Callable[[Dict[str, Any]], None],
                 on_connect: Callable[[], None],
                 on_disconnect: Callable[[], None],
                 cid: int,
                 port: int):
        super().__init__(daemon=True)
        self.on_message = on_message
        self.on_connect = on_connect
        self.on_disconnect = on_disconnect
        self.conn = None
        self.stop_flag = threading.Event()
        self.lock = threading.Lock()
        try:
            self.sock = socket.socket(AF_VSOCK, SOCK_STREAM)
            self.sock.bind((cid, port))
            self.sock.listen(1)
            logger.info("Socket successfully created")
        except socket.error as err:
             raise SystemError(f"VSOCK server setup failed: {err}") from err

    def __del__(self):
        self.stop()

    @property
    def client(self):
        with self.lock:
            if self.conn is None:
                self.conn, _ = self.sock.accept()
                self.on_connect()
            return self.conn

    def close_connection(self):
        with self.lock:
            if self.conn is not None:
                self.conn.close()
                self.conn = None
                self.on_disconnect()

    def run(self):
        while not self.stop_flag.is_set():
            try:
                for msg in jsonl_reader(self.client):
                    self.on_message(msg)
            except socket.error as err:
                logger.error(f"VSOCK server error: {err}")
            self.close_connection()

    def send(self, data: Dict[str, Any]) -> bool:
        for _ in range(5):
            try:
                jsonl_send(self.client, data)
                return True
            except Exception:
                logger.error(f"Vsock server error, send failed! Retrying...")
                self.close_connection()
                continue
        return False


    def stop(self):
        self.stop_flag.set()
        time.sleep(1)
        try:
            self.close_connection()
        except: pass
        try:
            if self.sock: self.sock.close()
        except: pass

class VsockClient(threading.Thread):
    """Host Client: send/receive message to server."""
    def __init__(self, on_message: Callable[[Dict[str, Any]], None],
                 on_connect: Callable[[], None],
                 on_disconnect: Callable[[], None],
                 cid: int,
                 port: int):
        super().__init__(daemon=True)
        self.on_message = on_message
        self.on_connect = on_connect
        self.on_disconnect = on_disconnect
        self.conn = None
        self.stop_flag = threading.Event()
        self.lock = threading.Lock()
        self.port = port
        self.cid = cid

    @property
    def server(self) -> socket.socket:
        with self.lock:
            if self.conn is None:
                self.conn = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM)
                self.conn.connect((self.cid, self.port))
            return self.conn

    def close_connection(self):
        with self.lock:
            if self.conn is not None:
                self.conn.close()
                self.conn = None
                self.on_disconnect()


    def run(self):
        while not self.stop_flag.is_set():
            try:
                for msg in jsonl_reader(self.server):
                    self.on_message(msg)
            except socket.error as err:
                logger.error(f"VSOCK server error: {err}")
            self.close_connection()

    def send(self, data: Dict[str, Any]) -> bool:
        for _ in range(5):
            try:
                jsonl_send(self.server, data)
                return True
            except Exception:
                logger.error(f"Vsock server error, send failed! Retrying...")
                self.close_connection()
                continue
        return False

    def stop(self):
        self.stop_flag.set()
        time.sleep(1)
        try:
            self.close_connection()
        except: pass
