{ pkgs ? import <nixpkgs> { }, }:

let
  unstablenixpkgs = fetchTarball {
    url =
      "https://github.com/NixOS/nixpkgs/archive/34a26e5164c13b960cff8ea54ab3e4b5fec796a9.tar.gz";
    sha256 = "0iap44a9f92hrbgqf80q2sr69ixc4p06qsvw755wi11m2m2p4hqf";
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
    gst_all_1.gst-plugins-good
    gst_all_1.gst-libav
    libunwind
    elfutils
    orc

  ];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.pulseaudio.out}/lib
  '';

}
