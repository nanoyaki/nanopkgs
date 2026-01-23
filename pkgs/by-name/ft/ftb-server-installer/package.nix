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
  version = "1.0.32";

  src = fetchgit {
    url = "https://github.com/FTBTeam/FTB-Server-Installer.git";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-RGiUItmqBfGZmtcPmo6xFL3T4uaP2Xewt75aVmsqiD8=";
  };

  vendorHash = "sha256-RN0agjtcVJSGgSAVKWhJArSmqoBQ4kQK6ac4Np1O4pU=";

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
