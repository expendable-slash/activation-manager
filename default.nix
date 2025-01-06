lib:
let
  eval =
    {
      pkgs,
      modules ? [ ],
    }:
    lib.evalModules {
      modules = [ ./modules ] ++ modules;
      specialArgs = {
        inherit pkgs;
      } // (import ./modules/.mkPath.nix { inherit pkgs lib; });
    };
in
{
  lib = {
    inherit eval;
    __functor = _: eval;
    home-bundle = args: (eval args).config.bin.activate;
  };
}
