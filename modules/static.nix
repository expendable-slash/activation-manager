{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  options = {
    static = {
      derivations = mkOption {
        type = types.attrsOf types.package;
        default = { };
        description = "Derivations to merge into the static package";
      };

      result = mkOption {
        type = types.package;
        readOnly = true;
        description = "Resulting merge of all static derivations";
      };
    };
  };

  config.static = {
    result = pkgs.buildEnv {
      name = "am-static";
      paths = builtins.attrValues config.static.derivations;
    };
  };
}
