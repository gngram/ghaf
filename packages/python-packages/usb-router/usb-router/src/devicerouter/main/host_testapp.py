import argparse, json, sys, time
from devicerouter.host.notify import NotifyClient
from devicerouter.transports.schema import validate_schema

def build_parser():
    p = argparse.ArgumentParser(description="Host ↔ controller VM with GUI (vsock)")
    p.add_argument("--message", required=True, type=str, help="Message in Json string format to send to controller VM")
    p.add_argument("--guest-cid", type=int, required=True, help="controller VM guest CID (e.g., 101)")
    p.add_argument("--guest-port", type=int, default=7000, help="controller VM vsock listen port.")
    return p

def main():
    args = build_parser().parse_args()
    if validate_schema(json.loads(args.jsons)):
        client = NotifyClient(args.guest_cid, args.guest_port)
        client.send(json.loads(args.jsons))
    else:
        print ("Invalid schema!")

if __name__ == "__main__":
    main()

