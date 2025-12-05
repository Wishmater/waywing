{ pkgs ? import <nixpkgs>, unstable-pkgs ? import <nixpkgs> { } }:

unstable-pkgs.flutter.buildFlutterApplication rec {

  pname = "waywing";
  version = "0.0.16";

  src = ./..;

  # autoPubspecLock = src + "/pubspec.lock";
  pubspecLock = pkgs.lib.importJSON (src + "/pubspec.lock.json");
  gitHashes = pkgs.lib.importJSON (src + "/pubspecGitHashes.json");

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
    unstable-pkgs.zig_0_15

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
