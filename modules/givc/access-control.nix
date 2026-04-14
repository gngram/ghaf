# SPDX-FileCopyrightText: 2022-2026 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.ghaf.givc.accessControl;

  # Generate Arg condition
  mapCondition =
    cond: argName: target:
    let
      toCedarValue =
        v:
        if isString v then
          ''"${v}"''
        else if isBool v then
          (if v then "true" else "false")
        else
          toString v;
      targetList = "[ " + (concatStringsSep ", " (map toCedarValue target)) + " ]";
      firstTarget = toCedarValue (head target);
    in
    {
      # Equality checks
      "is" = "context.${argName} == ${firstTarget}";
      "not-is" = "context.${argName} != ${firstTarget}";

      # 'contains' checks if the context value contains the target head
      "contains" = "context.${argName}.contains(${firstTarget})";

      # 'in' checks if the context value exists within the provided Nix list
      "in" = "${targetList}.contains(context.${argName})";

      # 'not-in' negates the 'in' logic
      "not-in" = "!${targetList}.contains(context.${argName})";

      # Pattern matching
      "like" = "context.${argName} like ${firstTarget}";
    }
    .${cond};

  # Context Logic
  genContext =
    ctx:
    let
      baseLogic = mapCondition ctx.condition ctx.Argname ctx.targets;
    in
    if ctx.optional then "(context has ${ctx.Argname} && ${baseLogic})" else baseLogic;

  # Main Rule
  generateRule =
    effect: rule:
    let
      pInplace = if length rule.Sources == 1 then "== Source::\"${head rule.Sources}\"" else "";
      aInplace = if length rule.Actions == 1 then "== Action::\"${head rule.Actions}\"" else "";
      rInplace = if length rule.Modules == 1 then "== Service::\"${head rule.Modules}\"" else "";

      pWhen =
        if length rule.Sources > 1 then [ "principal in ${toCedarList "Source" rule.Sources}" ] else [ ];
      aWhen =
        if length rule.Actions > 1 then [ "action in ${toCedarList "Action" rule.Actions}" ] else [ ];
      rWhen =
        if length rule.Modules > 1 then [ "resource in ${toCedarList "Service" rule.Modules}" ] else [ ];

      contextWhen = map genContext rule.Context;
      allConditions = pWhen ++ aWhen ++ rWhen ++ contextWhen;

      toCedarList =
        prefix: list: "[ " + (concatStringsSep ", " (map (x: ''${prefix}::"${x}"'') list)) + " ]";
    in
    ''
      ${effect} (
          principal ${pInplace},
          action ${aInplace},
          resource ${rInplace}
      )
      ${optionalString (
        allConditions != [ ]
      ) "when {\n    ${concatStringsSep " && \n    " allConditions}\n};"}
    '';

  accessControlOptions = types.submodule {
    options = {
      Sources = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "List of VM IPs.";
      };
      Actions = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Givc RPC methods.";
      };
      Modules = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Givc module full name which includes the RPC method.";
      };
      Context = mkOption {
        description = "Arguments check in the RPC context.";
        default = [ ];
        type = types.listOf (
          types.submodule {
            options = {
              Argname = mkOption {
                type = types.str;
                description = "Argument name in the context.";
              };
              optional = mkOption {
                type = types.bool;
                default = false;
                description = "Do not fail if argument is missing.";
              };
              condition = mkOption {
                type = types.enum [
                  "is"
                  "not-is"
                  "in"
                  "not-in"
                  "contains"
                  "like"
                ];
                description = "Logic:
                    'is' (==),
                    'not-is' (!=),
                    'in' (targets.contains(context.arg)),
                    'not-in' (!targets.contains),
                    'contains' (context.arg.contains(targets[0])), Other elements in targets are ignored.
                    'like' (pattern).";
              };
              targets = mkOption {
                type = types.listOf (
                  types.oneOf [
                    types.str
                    types.int
                    types.bool
                  ]
                );
                description = "List of values to compare against.";
              };
            };
          }
        );
      };
    };
  };

in
{
  options.ghaf.givc.accessControl = {
    enable = mkEnableOption "access control for givc-agent and givc-admin";
    cedarRulesFile = mkOption {
      type = types.nullOr types.path;
      description = "Access control rule file, if provided `permit` and `forbid` rules will be ignored.";
      default = null;
    };
    permit = mkOption {
      type = types.listOf accessControlOptions;
      default = [ ];
      description = "List of allow-rules.";
    };
    forbid = mkOption {
      type = types.listOf accessControlOptions;
      default = [ ];
      description = "List of deny-rules (precedence over permit).";
    };
  };

  config = {

    #SAMPLE CONFIG
    ghaf.givc.accessControl = {
      enable = true;
      permit = [
        {
          Sources = [
            "127.0.0.1"
            "127.0.0.2"
          ];
          Modules = [
            "Hello"
            "world"
          ];
          Actions = [
            "SayHello"
            "SayGoodbye"
          ];
          Context = [
            {
              Argname = "VmName";
              condition = "is";
              targets = [
                "app-vm"
                "gui-vm"
              ];
              optional = true;
            }
            {
              Argname = "service";
              condition = "in";
              targets = [
                11
                15
                20
              ];
            }
          ];
        }
      ];

      forbid = [
        {
          Modules = [
            "Hello"
            "world"
          ];
          Actions = [ "DontSayHello" ];
        }
        {
          Modules = [ "Another" ];
          Actions = [ "GetReq" ];
          Context = [
            {
              Argname = "VmName";
              condition = "is";
              targets = [ "gui-vm" ];
            }
          ];
        }
      ];
    };
    #############

    environment.etc."givc-access-control.cedar".text =
      if cfg.cedarRulesFile != null then
        builtins.readFile cfg.cedarRulesFile
      else
        (concatMapStringsSep "\n" (generateRule "permit") cfg.permit)
        + "\n"
        + (concatMapStringsSep "\n" (generateRule "forbid") cfg.forbid);
  };
}
