# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildGoModule,

  _sources,
  _versions,
}:

buildGoModule (finalAttrs: {
  inherit (_sources.ftb-server-installer) pname src;
  version = lib.removePrefix "v" _sources.ftb-server-installer.version;
  inherit (_versions.ftb-server-installer) vendorHash;

  patches = [ ./sum.patch ];

  env.CGO_ENABLED = 0;

  ldflags = [
    "-X 'ftb-server-downloader/util.ReleaseVersion=v${finalAttrs.version}'"
  ];

  meta = {
    description = "Server resource downloader for FTB modpacks.";
    homepage = "https://github.com/FTBTeam/FTB-Server-Installer";
    changelog = "https://github.com/FTBTeam/FTB-Server-Installer/commits/master";
    maintainers = [ lib.maintainers.nanoyaki ];
    mainProgram = "ftb-server-donwloader";
    license = lib.licenses.unfree;
  };
})
