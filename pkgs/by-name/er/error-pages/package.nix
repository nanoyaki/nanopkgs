# SPDX-FileCopyrightText: 2742c755c049e75c1fbfeab0452091827dd25d9f225 Hana Kretzer <contact@nanoyaki.space>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  fetchNpmDeps,
  nodejs,
  npmHooks,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "error-pages";
  version = "0-unstable-2024-11-22";

  src = fetchFromGitHub {
    owner = "sapachev";
    repo = "error-pages";
    rev = "742c755c049e75c1fbfeab0452091827dd25d9f2";
    hash = "sha256-5oAnXUvY08brivS/BtyUelt4hU8MUFoeA9y075qRRGE=";
  };

  env.npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-6TLZlXHD6n+OxSL4ETV9ObVAgsra2kjg1glzFJYyMTc=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  buildPhase = ''
    runHook preBuild

    npm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    mv dist $out/share/error-pages

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "-F"
      "--version=branch"
    ];
  };

  meta = {
    homepage = "https://github.com/sapachev/error-pages";
    description = "Lightweight tool for creating static custom HTTP error pages";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
    platforms = lib.platforms.all;
  };
})
