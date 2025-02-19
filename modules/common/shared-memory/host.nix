# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

{ config, lib, pkgs, ... }:
let
  cfg = config.ghaf.shm.host;
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;
  hugepages = if cfg.hugePageSz == "2M" then
                cfg.memSize / 2
              else
                cfg.memSize / 1024;

  user = "microvm";
  group = "kvm";
  memsocket = pkgs.callPackage ../../../packages/memsocket { shmSlots = config.ghaf.shm.numSlots; };
  vectors = toString (2 * config.ghaf.shm.numSlots);

  shmService = pkgs.writeShellScriptBin "shmService" ''
      if [ -S ${config.ghaf.shm.hostSocket} ]; then
        echo Erasing ${config.ghaf.shm.hostSocket}
        rm -f ${config.ghaf.shm.hostSocket}
      fi
      ${pkgs.qemu_kvm}/bin/ivshmem-server -p /tmp/ivshmem-server.pid -n ${vectors} -m /dev/hugepages/ -l ${(toString cfg.memSize) + "M"}i
    '';
in
{
  options.ghaf.shm.host = {
    enable = mkEnableOption "Enable shared memory for inter-vm data transfer";
    memSize = mkOption {
      type = types.int;
      default = 16;
      description = ''
        Specifies the size of the shared memory region, measured in
        megabytes (MB)
      '';
    };
    hugePageSz = mkOption {
      type = lib.types.enum [ "2M" "1G" ];
      default = "2M";
      description = ''
        Specifies the size of the large memory page area. Supported kernel
        values are 2 MB and 1 GB
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.kernelParams = [
      "hugepagesz=${cfg.hugePageSz}"
      "hugepages=${toString hugepages}"
    ];

    systemd.tmpfiles.rules = [
      "d /dev/hugepages 0755 ${user} ${group} - -"
    ];



    environment.systemPackages = [
      memsocket
    ];

    systemd.services.ivshmemsrv = {
      enable = true;
      description = "Start qemu ivshmem memory server";
      path = [ shmService ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StandardOutput = "journal";
        StandardError = "journal";
        ExecStart = "${shmService}/bin/shmService";
        User = user;
        Group = group;
      };
    };
  };
}
