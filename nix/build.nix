{
  pkgs ? import <nixpkgs>,
}:

let
  pubspecLock = pkgs.lib.importJSON ./../pubspec.lock.json;
  gitHashes = pkgs.lib.importJSON ./../pubspecGitHashes.json;

  nucleoDartSrc = pkgs.fetchFromGitHub {
    owner = "ross96D";
    repo = "nucleo.dart";
    rev = pubspecLock.packages.nucleo_dart.description."resolved-ref";
    sha256 = gitHashes.nucleo_dart;
  };

  nucleoRust = import "${nucleoDartSrc}/nix/build.nix" { inherit pkgs; };

in
pkgs.flutter.buildFlutterApplication {

  pname = "waywing";
  version = "0.0.18";

  src = ./..;

  inherit pubspecLock gitHashes;

  nativeBuildInputs = with pkgs; [

    # required by gtk-layer-shell
    gtk-layer-shell

    # required by audioplayers
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-libav
    libunwind
    elfutils
    orc

    # required by waywingcli
    zig

  ];

  preBuild = ''
    export PRECOMPILED_SO_PATH=${nucleoRust}/lib/libnucleo_dart.so
  '';

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
