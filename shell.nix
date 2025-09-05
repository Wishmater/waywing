{ pkgs ? import <nixpkgs> { }, }:

let
  unstablenixpkgs = fetchTarball {
    url =
      "https://github.com/NixOS/nixpkgs/archive/bf76d8af397b7a40586b4cbc89dc2e3d2370deaa.tar.gz";
    sha256 = "0si14qvhc0z0ip14gm9x7fw3bma8z260zf34g2hf54r5jnlnj9r8";
  };
  unstablepkgs = import unstablenixpkgs {
    config = { };
    overlays = [ ];
  };

in pkgs.mkShell {

  buildInputs = with pkgs; [

    jq
    yq

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

    # required by gtk-layer-shell
    ninja
    gtk-layer-shell

    # required by pulseaudio
    pulseaudio

    # required by audioplayers
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-libav
    libunwind
    elfutils
    orc

  ];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.pulseaudio.out}/lib
  '';

}
