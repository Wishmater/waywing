{
  description = "Waywing";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        build = import ./nix/build.nix { inherit pkgs; };
        dev-shell = import ./nix/dev-shell.nix { inherit pkgs; };
      in {
        packages.default = build; # Expose main package
        # packages = build; # All packages from build.nix

        devShells.default = dev-shell;
      });
}
