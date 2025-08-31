import argparse, json, os, sys
from pathlib import Path

from PyQt5.QtWidgets import QApplication

from devicerouter.guest.app_qt5 import App

DEFAULT_LISTEN_PORT = 7000

def build_parser():
    p = argparse.ArgumentParser(description="Guest USB controller")
    p.add_argument("--hostport", type=int, default=DEFAULT_LISTEN_PORT, help="vsock listen port")
    p.add_argument("--jsonfile", type=str, default="/run/usb-router/devices.json", help="TEST MODE: use this JSON file as transport")
    return p

def main():
    args = build_parser().parse_args()
    app = QApplication(sys.argv)

    jsonfile = args.jsonfile
    w = App(
        host_port=args.hostport,
        file_path=jsonfile
    )
    w.show()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
