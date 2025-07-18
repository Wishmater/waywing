{ pkgs ? import <nixpkgs> { }, }:

let
  unstablenixpkgs = fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  unstablepkgs = import unstablenixpkgs {
    config = { };
    overlays = [ ];
  };

in pkgs.mkShell {

  buildInputs = with pkgs; [

    unstablepkgs.flutter

    cmake
    clang

    pkg-config
    gtk3
    libsysprof-capture
    pcre2
    util-linux
    libselinux
    libsepol
    libthai
    libdatrie
    xorg.libXdmcp
    lerc
    libxkbcommon
    libepoxy
    xorg.libXtst

    ninja
    gtk-layer-shell

  ];

  shellHook = ''
    export PKG_CONFIG_PATH="${pkgs.gtk3.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
    export CMAKE_PREFIX_PATH="${pkgs.gtk3.dev}:${pkgs.libsecret.dev}"
  '';

}
