{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.bin = {
    activate = mkOption {
      type = types.package;
    };
  };

  config.bin = {
    activate = pkgs.writeShellScriptBin "activate" ''
      set -eu

      AM_STATE_FILE=$HOME/.activation-manager
      AM_STATIC_NIX_STORE_PATH=${config.static.derivations."path"}

      # Remove symlinks from the previous configuration.
      if [[ -f $AM_STATE_FILE ]]; then
        prevAMStaticPath=$(cat "$AM_STATE_FILE")
        while IFS= read -r -d "" sourcePath; do
          prefix="''${sourcePath#"$prevAMStaticPath"}"
          destPath="$HOME$prefix"

          rm "$destPath" 2>/dev/null || true

          # Recursively delete empty parent directories excluding $HOME.
          # Otherwise, it might try to delete $HOME and exit with a
          # permission error.
          destDir="$(dirname "$destPath")"
          if [[ -d "$destDir" && "$destDir" != "$HOME" ]]; then
            # macOS doesn't support `--ignore-fail-on-non-empty` option.
            rmdir -p "$destDir" 2>/dev/null || true
          fi
        done < <(find "$prevAMStaticPath" -type l -print0)
      fi

      # For every file in the am-static-path tree, create a corresponding
      # symlink in the home directory.
      while IFS= read -r -d "" sourcePath; do
        prefix="''${sourcePath#"$AM_STATIC_NIX_STORE_PATH"}"
        destPath="$HOME$prefix"
        destDir="$(dirname "$destPath")"
        if [[ ! -d "$destDir" ]]; then
          mkdir -p "$destDir"
        fi

        ln -sf "$sourcePath" "$destPath"
      done < <(find "$AM_STATIC_NIX_STORE_PATH" -type l -print0)

      # Update $HOME/.activation-manager to point at the AM-STATIC-PATH
      # files of the current configuration.
      echo "$AM_STATIC_NIX_STORE_PATH" >"$AM_STATE_FILE"
    '';
  };
}
