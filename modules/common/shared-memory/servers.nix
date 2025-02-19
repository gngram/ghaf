{
  lib,
  config,
  pkgs,
  vmName,
  configHost,
  ...
}:
let
  inherit (lib)
    findFirst
    mkOption
    mkIf
    mkMerge
    types
  ;
  cfg = config.ghaf.shm.server;
  vectors = toString (2 * config.ghaf.shm.numSlots);
  memsocket = pkgs.callPackage ../../../packages/memsocket { shmSlots = config.ghaf.shm.numSlots; };

  createService = client: lib.attrsets.recursiveUpdate {
    enable = true;
    description = "memsocket";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${memsocket}/bin/memsocket -s ${config.ghaf.shm.serverSocket vmName client.name} -l ${client.slot}";
      Restart = "always";
      RestartSec = "1";
      RuntimeDirectory = "memsocket-${vmName}";
      RuntimeDirectoryMode = "0750";
    };
  } cfg.serviceParams;

  systemdServiceConfig =  clients: builtins.listToAttrs (map (client: {
    name = "memsocket-${vmName}-${client.name}";
    value = createService client;
  }) clients);

  vmSlotType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "The name of the VM.";
        example = "business-vm";
      };

      slot = mkOption {
        type = types.int;
        description = "The slot number assigned to the VM.";
        example = 0;
      };
    };
  };
in
{
  options.ghaf.shm.server = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable shm server.";
    };
    clients = mkOption {
      type = types.listOf vmSlotType;
      default = [];
      description = "List of clients and their slots.";
    };
    /*
    multiProc = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to run separate process for each client";
    };
    */
    userService = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to run as a user service.";
    };

    serviceParams = mkOption {
      type = types.attrs;
      default = {};
      description = "Systemd service parameters.";
    };
  };

  config = mkIf config.ghaf.shm.server.enable {
    /*
    systemd = if cfg.userService then {
      if cfg.multiProc then {
        user.services = systemdServiceConfig config.ghaf.shm.server.clients;
      } else {
        services = systemdServiceConfig config.ghaf.shm.server.clients;
      };
    } else {
      if cfg.multiProc then {
        user.services = systemdServiceConfig ["clients"];
      } else {
        services = systemdServiceConfig ["clients"];;
      };
    };
    */
    systemd = if cfg.userService then {
      user.services = systemdServiceConfig config.ghaf.shm.server.clients;
    } else {
      services = systemdServiceConfig config.ghaf.shm.server.clients;
    };
  };
}
