{ pkgs ? import <nixpkgs> }:

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

in unstablepkgs.flutter.buildFlutterApplication rec {

  pname = "waywing";
  version = "0.0.9";

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
    gst_all_1.gst-plugins-good
    gst_all_1.gst-libav
    libunwind
    elfutils
    orc

    # required by waywingcli
    unstablepkgs.zig_0_15

  ];

  # we have to do the zig stuff in postBuild and postInstall so they don't override
  # default buildFlutterApplication phases
  postBuild = ''
    (cd tools/waywingctl && zig build -Doptimize=ReleaseSmall)
  '';

  postInstall = ''
    mv tools/waywingctl/zig-out/bin/waywingctl $out/bin/waywingctl
    # add runtime environment variables to waywing
    wrapProgram "$out/bin/waywing" \
      --set LD_LIBRARY_PATH ${pkgs.pulseaudio.out}/lib
  '';

  # # env variables accessible to the built app at runtime, this doesn't seem to work...
  # runtimeEnvironment = { LD_LIBRARY_PATH = "${pkgs.pulseaudio.out}/lib"; };
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
