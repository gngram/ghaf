import argparse, json, sys, time
from devicerouter.host.service import HostService

def build_parser():
    p = argparse.ArgumentParser(description="Host ↔ Conroller VM")
    p.add_argument("--port", type=int, default=7000, help="Host vsock listen port (default 7000)")
    return p

def main():
    args = build_parser().parse_args()
    svc = HostService(args.port)
    svc.start()
    try:
        print("[HOST] Running. Ctrl+C to exit.")
        svc.wait()
    except KeyboardInterrupt:
        pass
    finally:
        svc.stop()

if __name__ == "__main__":
    main()

