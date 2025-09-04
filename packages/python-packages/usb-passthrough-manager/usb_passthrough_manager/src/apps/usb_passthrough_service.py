# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

import argparse
from usb_passthrough_manager.guest.registry_service import RegistryService
from usb_passthrough_manager.logger import setup_logger
import logging
from pathlib import Path
import os


logger = logging.getLogger("usb_passthrough_manager")

def build_parser():
    p = argparse.ArgumentParser(description="controller VM ↔ HOST (vsock)")
    p.add_argument("--cid", type=int, default=5, help="Host vsock listen port (default 5)")
    p.add_argument("--port", type=int, default=7000, help="Host vsock listen port (default 7000)")
    p.add_argument("--dir", type=str, default="/run/usb-passthrough-manager/", help="Directory to store registry")
    p.add_argument("--loglevel", type=str, default="info", help="Log level")
    return p

def main():
    args = build_parser().parse_args()
    setup_logger(args.loglevel)

    svc = RegistryService(args.cid, args.port, args.dir)
    svc.start()
    fifo = Path(args.dir) / "switch.fifo"
    try:
        if fifo.exists():
            os.unlink(fifo)
        os.mkfifo(fifo, 0o622)  # write only for others
    except FileExistsError:
        raise RuntimeError("Can not create FIFO!")

    with open(fifo, "r", encoding="utf-8") as f:
        for line in f:
            device_id, new_vm = line.rstrip("\n").split("->", 1)
            if not svc.request_switch(device_id, new_vm):
                logger.error(f"Failed to send vm_switch request")
            else:
                logger.info(f"vm_switch request sent successfuly to host: {device_id} -> {new_vm}")

    try:
        svc.wait()
    except KeyboardInterrupt:
        pass
    finally:
        svc.stop()
        os.unlink(fifo)

if __name__ == "__main__":
    main()
