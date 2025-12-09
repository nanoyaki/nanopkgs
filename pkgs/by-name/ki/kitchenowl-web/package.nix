# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  flutter,
  fetchFromGitHub,
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
  targetFlutterPlatform = "web";

  autoPubspecLock = src + "/kitchenowl/pubspec.lock";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "-F"
      "--version"
      "branch"
    ];
  };
}
