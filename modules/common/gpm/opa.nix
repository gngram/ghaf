{ config, pkgs, lib, ... }:

let
  opaPolicy = ''
    package authz
    default allow = false
    allow if {
        input.role == "admin"
    }
    allow if {
        input.client_ip == "192.168.1.10"
    }
  '';
in {
  options = {
    ghaf.services.opa =  {
      enable = lib.mkOption {
        description = ''
          Enable Open policy agent.
        '';
        type = lib.types.bool;
        default = false;
      };

      port = lib.mkOption {
        description = ''
          Port to listen.
        '';
        type = lib.types.int;
        default = 5050;
      };
    };
  };

  config = lib.mkIf config.ghaf.services.opa.enable {
    environment.systemPackages = [ pkgs.open-policy-agent ];
    systemd.services.opa = {
      description = "Open Policy Agent (OPA)";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.open-policy-agent}/bin/opa run --server --addr 0.0.0.0:${toString config.ghaf.services.opa.port} /etc/opa/policy.rego";
        Restart = "always";
        User = "opa";
        Group = "opa";
        WorkingDirectory = "/etc/opa";
      };
    };

    environment.etc."opa/policy.rego".text = opaPolicy;
  };
}
