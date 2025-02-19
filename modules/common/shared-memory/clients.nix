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
  memsocket = pkgs.callPackage ../../../packages/memsocket { shmSlots = config.ghaf.shm.numSlots; };

  createService = server: lib.attrsets.recursiveUpdate {
    enable = true;
    description = "memsocket";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${memsocket}/bin/memsocket -s ${config.ghaf.shm.clientSocket server.name} -l ${server.slot}";
      Restart = "always";
      RestartSec = "1";
      RuntimeDirectory = "memsocket-${server.name}";
      RuntimeDirectoryMode = "0750";
    };
  } cfg.serviceParams;

  getServers = clientName:
    builtins.concatMap (serverName:
      let
        server = servers.${serverName};  # Get the server config
      in
        if server.enable then
          # Filter clients belonging to the given server
          map (c: { name = serverName; slot = c.slot; })
              (builtins.filter (c: c.name == clientName) server.clients)
        else
          []  # Skip disabled servers
    ) (builtins.attrNames config.ghaf.shm.servers)



  servers = getServers vmName;


  systemdServiceConfig =  serverList: builtins.listToAttrs (map (server: {
    name = "memsocket-${server.name}";
    value = createService server;
  }) serverList);


in
{
  options.ghaf.shm.client = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable shm client.";
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
