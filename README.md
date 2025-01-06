# activation-manager (new name TBD)

Heavily modified (hacked together) version of [original](https://github.com/viperML/activation-manager).

## Usage

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    activation-manager = {
      url = "github:expendable-slash/activation-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      activation-manager,
    }:
    {
      packages."aarch64-darwin".default =
        with nixpkgs.legacyPackages.aarch64-darwin;
        buildEnv {
          name = "home";
          paths = [
            # regular packages
            git
            fish

            # symlink config files from nix store
            # to home directory
            (activation-manager.lib.home-bundle {
              inherit pkgs;
              modules = [
                {
                  path.".ssh/config".source = ./sshconfig;

                  # destination will be `$HOME/.poo/config`
                  # path.".ssh/config" = {
                  #   source = ./sshconfig;
                  #   destination = ".poo/config";
                  #   enable = false;
                  # };

                  # destination will be `$HOME/boo/.ssh/config`
                  # path.".ssh/config" = {
                  #   source = ./sshconfig;
                  #   prefix = "boo";
                  #   enable = false;
                  # };

                  path."Library/Application Support/Code/User/settings.json".source = ./vscode_settings.json;
                }
              ];
            })
          ];
        };
    };
}
```

```
$ nix profile install /path/to/flake && activate
```
