{
  description = "Escape game sound system";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    gepetto-lib.url = "github:Gepetto/nix-lib";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      perSystem =
        {
          pkgs,
          self',
          ...
        }:
        {
          packages = {
            default = self'.packages.alloria;
            alloria = pkgs.callPackage ./. {
              version = inputs.gepetto-lib.lib.pythonVersion pkgs ./pyproject.toml;
            };
          };
        };
      flake = {
        nixosModules = {
          control = import ./control.nix;
          escape = import ./escape.nix;
        };
      };
    };
}
