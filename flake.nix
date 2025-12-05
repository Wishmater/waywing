{
  description = "Waywing";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    unstable-nixpkgs.url =
      "github:nixos/nixpkgs/34a26e5164c13b960cff8ea54ab3e4b5fec796a9";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, unstable-nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        unstable-pkgs = unstable-nixpkgs.legacyPackages.${system};
        build = import ./nix/build.nix {
          inherit pkgs;
          inherit unstable-pkgs;
        };
        dev-shell = import ./nix/dev-shell.nix {
          inherit pkgs;
          inherit unstable-pkgs;
        };
      in {
        packages.default = build; # Expose main package
        # packages = build; # All packages from build.nix

        devShells.default = dev-shell;
      });
}
