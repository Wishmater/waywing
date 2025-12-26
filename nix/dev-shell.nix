{ pkgs ? import <nixpkgs> { } }:

let build = import ./build.nix { inherit pkgs; };

in pkgs.mkShell {

  # Inherits all buildInputs/nativeBuildInputs from build.nix 
  inputsFrom = [ build ];

  # Add other packages needed for dev, but not for build
  buildInputs = with pkgs; [

    jq
    yq

    flutter

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

    # required by gtk-layer-shell
    ninja

    # required by pulseaudio
    pulseaudio

  ];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.pulseaudio.out}/lib
  '';

}
