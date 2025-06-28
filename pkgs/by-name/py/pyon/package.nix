# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  rustPlatform,
  nix-update-script,

  _sources,
}:

rustPlatform.buildRustPackage {
  inherit (_sources.pyon) pname version src;

  useFetchCargoVendor = true;
  cargoHash = "sha256-uOY5vRzQ2MVLdgdpDkbLdMTScWxVyzq57v3WQJGFQAM=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Print ASCII and braille bunnies to your terminal";
    homepage = "https://github.com/nanoyaki/pyon";
    license = lib.licenses.mit;
    mainProgram = "pyon";
  };
}
