{ pkgs ? import <nixpkgs> { } }:

let
  build = import ./build.nix;
  app = pkgs.callPackage build { };

in pkgs.mkShell { buildInputs = [ app ]; }
