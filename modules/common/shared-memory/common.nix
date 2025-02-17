# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.ghaf.shm;
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;

  slotMap = types.submodule {
    options = {
      clients = mkOption {
        type = types.int;
        description = "List of clients with name and slot.";
      };
    };
  };

/*
  shmClient = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "The name of the client.";
      };

      slot = mkOption {
        type = types.int;
        description = "The slot number of the client.";
      };
    };
  };

  shmServer = types.submodule {
    options = {
      clients = mkOption {
        type = types.listOf shmClient;
        default = [];
        description = "List of clients with name and slot.";
      };
      clientSocket = mkOption {
        type = types.path;
        description = "Socket path for clients";
      };
    };
  };
*/
  memsocket = pkgs.callPackage ../../../packages/memsocket { shmSlots = config.ghaf.shm.config.numSlots; };
  vectors = toString (2 * config.ghaf.shm.config.numSlots);

in
{
  options.ghaf.shm = {
    enable = mkEnableOption "Enable shared memory for inter-vm data transfer";
    config = {
      /*
      servers = mkOption {
        type = types.attrsOf shmServer;
        default = {};
        description = "A module that allows defining shm server configs.";
      };

      slotMap = mkOption {
        readOnly = true;
        type = types.attrsOf slotMap;
        description = "Slot map for client VMs.";
      };
      */
      phyAddr = mkOption {
        type = types.str;
        description = ''
          Maps the shared memory to a physical address if set to a non-zero value.
          The address must be platform-specific and arbitrarily chosen to avoid
          conflicts with other memory areas, such as PCI regions.
        '';
      };

      hostSocket = mkOption {
        readOnly = true;
        type = types.path;
        description = "Path to the shared memory socket.";
      };

      numSlots = mkOption {
        readOnly = true;
        type = types.int;
        description = ''
          Total available slots.
        '';
      };
      qemuExtraArgs = mkOption {
        type = types.listOf types.str;
        readOnly = true;
        description = ''
          Extra arguments to pass to qemu when enabling shared memory client/server.
        '';
        example = [
          "-device"
          "ivshmem-doorbell,vectors=5,chardev=ivs_socket,flataddr=0x90000000"
        ];
      };
      extraKernelParams = mkOption {
        type = types.listOf types.str;
        readOnly = true;
        description = ''
          Kernel parameters to pass to qemu when enabling shared memory client/server.
        '';
        example = [
          "kvm_ivshmem.flataddr=0x90000000"
        ];
      };
    };
  };

  config = {
    # One extra slot for host
    #TODO:
    ghaf.shm.config.numSlots = 10;
    ghaf.shm.config.hostSocket = "/tmp/ivshmem_socket";

    ghaf.shm.config.qemuExtraArgs = [
      "-device"
      "ivshmem-doorbell,vectors=${vectors},chardev=ivs_socket,flataddr=${config.ghaf.shm.config.phyAddr}"
      "-chardev"
      "socket,path=${config.ghaf.shm.config.hostSocket},id=ivs_socket"
    ];
    ghaf.shm.config.extraKernelParams = [ "kvm_ivshmem.flataddr=${config.ghaf.shm.config.phyAddr}" ];

    boot.extraModulePackages = [
      (pkgs.linuxPackages.callPackage ../../../packages/memsocket/module.nix {
        inherit (config.boot.kernelPackages) kernel;
        shmSlots = config.ghaf.shm.config.numSlots;
      })
    ];
    services = {
      udev = {
        extraRules = ''
          SUBSYSTEM=="misc",KERNEL=="ivshmem",GROUP="kvm",MODE="0666"
        '';
      };
    };

    environment.systemPackages = [
      memsocket
    ];

  };
}
