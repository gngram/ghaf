# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

import argparse, os, sys
from PyQt5.QtWidgets import QApplication

from usb_passthrough_manager.guest.app_qt5 import App
from usb_passthrough_manager.logger import setup_logger
import logging

logger = logging.getLogger("usb_passthrough_manager")

def build_parser():
    p = argparse.ArgumentParser(description="Guest USB controller")
    p.add_argument("--hostport", type=int, default=7000, help="vsock listen port")
    p.add_argument("--dir", type=str, default="/run/usb_hotplug_manager/", help="Database directory for USB device manager, should be same as usb passthrough manager service")
    p.add_argument("--loglevel", type=str, default="info", help="Log level")
    return p

def main():
    args = build_parser().parse_args()
    app = QApplication(sys.argv)
    setup_logger(args.loglevel)
    logger.info("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT")

    jsonfile = os.path.join(args.dir, "usb_db.json")
    w = App(
        host_port=args.hostport,
        file_path=jsonfile
    )
    w.show()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
