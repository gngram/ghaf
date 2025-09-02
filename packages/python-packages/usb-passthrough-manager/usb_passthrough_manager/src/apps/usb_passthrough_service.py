# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

import argparse
from usb_passthrough_manager.guest.registry_service import RegistryService
from usb_passthrough_manager.logger import setup_logger
import logging

logger = logging.getLogger("usb_passthrough_manager")

def build_parser():
    p = argparse.ArgumentParser(description="controller VM ↔ HOST (vsock)")
    p.add_argument("--port", type=int, default=7000, help="Host vsock listen port (default 7000)")
    p.add_argument("--dir", type=str, default="/run/usb_hotplug_manager/", help="Directory to store registry")
    p.add_argument("--loglevel", type=str, default="info", help="Log level")
    return p

def main():
    args = build_parser().parse_args()
    setup_logger(args.loglevel)
    logger.info("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT")

    svc = RegistryService(args.port, args.dir)
    svc.start()
    try:
        svc.wait()
    except KeyboardInterrupt:
        pass
    finally:
        svc.stop()

if __name__ == "__main__":
    main()
