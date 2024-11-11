import os
from systemdservice import SystemdService
import sys
import argparse


def check_sudo():
    if os.geteuid() != 0:
        print("This program must be run as root (use sudo).")
        sys.exit(1)

def main():
    check_sudo()
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Generate hardened configuration for service.')
    parser.add_argument('service', type=str, help='Name of the service')
    parser.add_argument('output', type=str, help='Output file path to save hardened configuration')
    parser.add_argument('--residue', type=str, help='Service residues to clear before service restart.', default="")
    parser.add_argument('--latency', type=int, help='Service latency in seconds.', default=2)

    # Parse the command-line arguments
    args = parser.parse_args()

    service = SystemdService(args.service, args.residue, args.latency)
    old_exposure = service.get_exposure()
    hardened_configs = service.get_hardened_configs()
    print(hardened_configs)
    configs = "\n".join(hardened_configs)
    with open(args.output, 'w') as file:
        file.write(configs)
    new_exposure = service.get_exposure()
    print(f"Exposure level before: [{old_exposure}] and after: [{new_exposure}]")

if __name__ == "__main__":
    main()
