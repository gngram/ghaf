import argparse, json, sys, time
from devicerouter.guest.registry_service import RegistryService

def build_parser():
    p = argparse.ArgumentParser(description="controller VM ↔ HOST (vsock)")
    p.add_argument("--port", type=int, default=7000, help="Host vsock listen port (default 7000)")
    p.add_argument("--dir", type=str, default="/run/usb-router", help="Directory to store registry (default /run/usb-router)")
    return p

def main():
    args = build_parser().parse_args()
    svc = RegistryService(args.port, args.dir)
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

