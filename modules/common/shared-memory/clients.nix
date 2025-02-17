{
  lib,
  config,
  pkgs,
  vmName,
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
  cfg = config.ghaf.shm.client;
  memsocket = pkgs.callPackage ../../../packages/memsocket { shmSlots = config.ghaf.shm.config.numSlots; };

  createService = shmServer: lib.attrsets.recursiveUpdate {
    enable = true;
    description = "memsocket";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${memsocket}/bin/memsocket -s /tmp/${shmServer.name}-client.sock -l ${shmServer.slot}";
      Restart = "always";
      RestartSec = "1";
      RuntimeDirectory = "memsocket-${shmServer.name}";
      RuntimeDirectoryMode = "0750";
    };
  } cfg.serviceParams;

  /*
  servers = builtins.concatLists (
    builtins.mapAttrsToList (serverName: serverConfig:
      builtins.filter (client: client.name == ${vmName}) serverConfig.clients
        builtins.map (client: { inherit serverName; slot = client.slot; })
    ) config.ghaf.shm.config.servers
  );
  */

  systemdServiceConfig =  serverList: builtins.listToAttrs (map (server: {
    name = "memsocket-${server.name}";
    value = createService server;
  }) serverList);

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
  options.ghaf.shm.client = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable shm client.";
    };

    servers = mkOption {
      type = types.listOf vmSlotType;
      default = [];
      description = "List of clients and their slots.";
    };

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
    systemd = if cfg.userService then {
      user.services = systemdServiceConfig config.ghaf.shm.client.servers;
    } else {
      services = systemdServiceConfig config.ghaf.shm.client.servers;
    };
  };
}
