{ pkgs ? import <nixpkgs> }:

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

in unstablepkgs.flutter.buildFlutterApplication rec {

  pname = "waywing";
  version = "0.0.8";

  src = ./..;

  # autoPubspecLock = src + "/pubspec.lock";
  pubspecLock = pkgs.lib.importJSON (src + "/pubspec.lock.json");
  gitHashes = pkgs.lib.importJSON (src + "/pubspecGitHashes.json");

  nativeBuildInputs = with pkgs; [

    # required by gtk-layer-shell
    gtk-layer-shell

    # # required by pulseaudio
    # pulseaudio 

    # required by audioplayers
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-libav
    libunwind
    elfutils
    orc

  ];

  # env variables accessible to the built app at runtime
  # runtimeEnvironment = { LD_LIBRARY_PATH = "${pkgs.pulseaudio.out}/lib"; };
  postInstall = ''
    wrapProgram "$out/bin/waywing" \
      --set LD_LIBRARY_PATH ${pkgs.pulseaudio.out}/lib
  '';
}

# # USAGE
#
# { pkgs, ... }:
#
# let
#   waywingSrc = pkgs.fetchFromGitHub {
#     owner = "Wishmater";
#     repo = "waywing";
#     rev = <version>;
#     sha256 = "";
#   };
#   waywingBuild = import "${waywingSrc}/nix/build.nix";
#   waywing = pkgs.callPackage waywingBuild { };
#
# in {
#
#   environment.systemPackages = [ waywing ];
#
# }
