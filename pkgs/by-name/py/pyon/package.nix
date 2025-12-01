# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  rustPlatform,
  fetchgit,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pyon";
  version = "0.1.0";

  src = fetchgit {
    url = "https://github.com/nanoyaki/pyon.git";
    rev = "06a076e7be314813ff71d823f200e6c3e0b2d232";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-SgMYeWSQP3hk6t5jBHP2lIPe3ig7PFEhY2KnIHKM76s=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-uOY5vRzQ2MVLdgdpDkbLdMTScWxVyzq57v3WQJGFQAM=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "-F" ]; };

  meta = {
    description = "Print ASCII and braille bunnies to your terminal";
    homepage = "https://github.com/nanoyaki/pyon";
    license = lib.licenses.mit;
    mainProgram = "pyon";
  };
})
