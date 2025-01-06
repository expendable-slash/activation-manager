# This file creates the options and config needed for the path option.
# A path option is a submodule where users can set paths to be activated
# to the static dir, like nixos's `environment.etc` or home-manager's `home.file`.
{
  pkgs,
  lib,
}:
let
  inherit (lib)
    mkOption
    types
    ;

  pathModule =
    defaultPrefix:
    {
      name,
      config,
      ...
    }:
    {
      options = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether this path is used or not";
        };

        source = mkOption {
          type = types.path;
          description = "Source path";
        };

        destination = mkOption {
          type = types.str;
          description = "Destination path";
          default = name;
        };

        prefix = mkOption {
          type = types.str;
          description = "Prefix to prepend to destination path";
          default = defaultPrefix;
        };
      };
    };

  mkPathOption =
    defaultPrefix:
    mkOption {
      default = { };
      type = types.attrsOf (types.submodule (pathModule defaultPrefix));
    };

  mkPathConfig =
    cfg: cfgName:
    let
      pathsList = lib.filter (f: f.enable) (lib.attrValues cfg);
    in
    {
      static.derivations.${cfgName} = pkgs.runCommand "am-static-${cfgName}" { } ''
        trap "set +x" ERR
        set -x
        mkdir -p $out

        ${lib.concatMapStringsSep "\n" (value: ''
          destFile="$out/${value.prefix}${value.destination}"
          destDir="$(dirname "$destFile")"
          mkdir -p "$destDir"
          ln -vsfT ${value.source} "$destFile"
        '') pathsList}

        set +x
      '';
    };
in
{
  inherit mkPathConfig mkPathOption;
}
