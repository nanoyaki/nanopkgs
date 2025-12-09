# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  flutter,
  fetchFromGitHub,
  util-linux,
  imagemagick,
  makeDesktopItem,
  nix-update-script,
}:

flutter.buildFlutterApplication rec {
  pname = "kitchenowl-${targetFlutterPlatform}";
  version = "0.7.4-unstable-2025-12-06";

  src = fetchFromGitHub {
    owner = "TomBursch";
    repo = "Kitchenowl";
    rev = "c26188f5926a70cb6d899fdcf29ca2c5e6480484";
    hash = "sha256-rZn2nty/O2soYX9PJYlZqCtb0NjsfjMZTsxHAWLVkXA=";
  };

  sourceRoot = "${src.name}/kitchenowl";
  targetFlutterPlatform = "linux";

  nativeBuildInputs = [ imagemagick ];
  runtimeDependencies = [ util-linux ];

  autoPubspecLock = src + "/kitchenowl/pubspec.lock";

  desktopItem = makeDesktopItem {
    name = "kitchenOwl";
    exec = "kitchenowl";
    icon = "kitchenowl";
    desktopName = "kitchenOwl";
    genericName = "smart grocery list and recipe manager";
    categories = [
      "Office"
      "Utility"
      "Finance"
    ];
    mimeTypes = [ "x-scheme-handler/kitchenowl" ];
  };

  # error: identifier '_json' preceded by whitespace in a literal operator
  env.NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-literal-operator";

  postInstall = ''
    #FAV=$out/app/data/flutter_assets/assets/icon/icon.png
    FAV=assets/icon/icon.png
    ICO=$out/share/icons

    install -D $FAV $ICO/kitchenowl.png
    mkdir $out/share/applications
    cp $desktopItem/share/applications/*.desktop $out/share/applications
    for size in 24 32 42 64 128 256 512; do
      D=$ICO/hicolor/''${s}x''${s}/apps
      mkdir -p $D
      convert $FAV -resize ''${size}x''${size} $D/kitchenowl.png
    done
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "-F"
      "--version"
      "branch"
    ];
  };
}
