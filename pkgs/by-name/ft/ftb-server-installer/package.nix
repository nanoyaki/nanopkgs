# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildGoModule,
  fetchgit,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "ftb-server-installer";
  version = "1.0.31";

  src = fetchgit {
    url = "https://github.com/FTBTeam/FTB-Server-Installer.git";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-PpsJAMOlOCAGY2OL0LmowIJ4WhjMqIJZKUlhoy4XQSM=";
  };

  vendorHash = "sha256-j/3iys3EA9RBwqUoaN/Xjc9UmjdXrtEC+Zuk8BMSXiI=";

  patches = [ ./sum.patch ];

  env.CGO_ENABLED = 0;

  ldflags = [
    "-X 'ftb-server-downloader/util.ReleaseVersion=v${finalAttrs.version}'"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "-F" ]; };

  meta = {
    description = "Server resource downloader for FTB modpacks.";
    homepage = "https://github.com/FTBTeam/FTB-Server-Installer";
    changelog = "https://github.com/FTBTeam/FTB-Server-Installer/commits/master";
    maintainers = [ lib.maintainers.nanoyaki ];
    mainProgram = "ftb-server-donwloader";
    license = lib.licenses.unfree;
  };
})
