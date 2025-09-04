# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

import argparse
import logging
import os
import json

from usb_passthrough_manager.host.service import HostService
from usb_passthrough_manager.logger import setup_logger
from pathlib import Path


logger = logging.getLogger("usb_passthrough_manager")

def emulate(svc):
    fifo = Path(args.dir) / "switch.fifo"
    try:
        if fifo.exists():
            os.unlink(fifo)
        os.mkfifo(fifo, 0o622)  # write only for others
    except FileExistsError:
        raise RuntimeError("Can not create FIFO!")
    with open(fifo, "r", encoding="utf-8") as f:
        for line in f:
            try:
                request = json.loads(line.rstrip("\n"))
            except json.JSONDecodeError as e:
                logger.error("JSON parse failed! Send new command!")
                continue
            if "type" not in request:
                logger.error("Could not find type field in request! Send new command!")
                continue
            match request["type"]:
                case "switch_request":
                    if "device_id" not in request or "current-vm" not in request:
                        logger.error("Could not find device_id or current-vm field in request! Send new command!")
                    else:
                        device_id = request.get("device_id")
                        target_vm = request.get("current-vm")
                        if not svc.notify_device_switch(device_id, target_vm):
                            logger.error(f"Notify error! Service restart required.")
                        else:
                            logger.info(f"Device {device_id} switched to VM {target_vm}")
                    continue
                case "reset":
                    if not svc.reset():
                        logger.error(f"Couldn't send reset request.")
                    continue
                case "device_connected":
                    if "device" not in request:
                        logger.error("Could not find device field in request! Send new command!")
                    else if "device_id" not in request["device"]
                            or "vendor" not in request["device"]
                        or "product" not in request["device"]
                        or "permitted-vms" not in request["device"]
                        or "current-vm" not in request["device"]:

:
:"




def build_parser():
    p = argparse.ArgumentParser(description="Host ↔ Conroller VM")
    p.add_argument("--cid", type=int, default=5, help="GUI VM vsock CID (default: 5)")
    p.add_argument("--port", type=int, default=7000, help="GUI VM vsock port for usb passthrough manager service (default 7000)")
    p.add_argument("--loglevel", type=str, default="info", help="Log level")
    p.add_argument("--emulate", type=bool, default=False, help="Emulate mode(test)")
    return p

def main():
    args = build_parser().parse_args()
    setup_logger(args.loglevel)

    svc = HostService(port = args.port, cid = args.cid)
    svc.start()
    logger.info("[HOST] Running. Ctrl+C to exit.")
    if args.emulate:
        emulate(svc)

    try:
        svc.wait()
    except KeyboardInterrupt:
        pass
    finally:
        svc.stop()

if __name__ == "__main__":
    main()
