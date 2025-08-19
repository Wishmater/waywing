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
  version = "0.0.1-3";

  src = pkgs.fetchFromGitHub {
    # https://github.com/ross96D/waywing
    owner = "Wishmater";
    repo = "waywing";
    # rev = "0.0.1";
    rev = "b962088a6635352b3c8eb1b10d4a69b26046c21f";
    sha256 = "sha256-02PRJqeUV7IhDLuKrm3d1eyYQ783/BCc/IAmJ1bX4pw=";
  };

  buildInputs = with pkgs; [
    # unstablepkgs.flutter

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

    pulseaudio
  ];

  autoPubspecLock = src + "/pubspec.lock";

  # Skip CMake configuration
  configurePhase = "true";

  buildPhase = ''
    export HOME=$(mktemp -d)

    export PKG_CONFIG_PATH="${pkgs.gtk3.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
    export CMAKE_PREFIX_PATH="${pkgs.gtk3.dev}:${pkgs.libsecret.dev}"

    export LD_LIBRARY_PATH=${pkgs.pulseaudio.out}/lib

    runHook preBuild
    # mkdir -p build/flutter_assets/fonts
    flutter --disable-analytics
    flutter pub get --offline
    flutter build linux --release --offline
    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv build/linux/x64/release/bundle/* $out/bin/
  '';
}
