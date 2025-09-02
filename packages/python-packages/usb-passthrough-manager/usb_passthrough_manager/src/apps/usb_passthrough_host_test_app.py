# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

import argparse, json
from usb_passthrough_manager.host.notify import NotifyClient
from usb_passthrough_manager.transports.schema import validate_schema
from usb_passthrough_manager.logger import setup_logger
import logging

logger = logging.getLogger("usb_passthrough_manager")


def build_parser():
    p = argparse.ArgumentParser(description="Host ↔ controller VM with GUI (vsock)")
    p.add_argument("--schema", required=True, type=str, help="Schema in Json string format to send to controller VM")
    p.add_argument("--cid", type=int, required=True, help="controller VM guest CID")
    p.add_argument("--port", type=int, default=7000, help="controller VM vsock listen port.")
    p.add_argument("--loglevel", type=str, default="info", help="Log level")
    return p

def main():
    args = build_parser().parse_args()
    setup_logger(args.loglevel)
    logger.info("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT")

    if validate_schema(json.loads(args.schema)):
        client = NotifyClient(args.cid, args.port)
        client.send(json.loads(args.schema))
    else:
        print ("Invalid schema!")

if __name__ == "__main__":
    main()
