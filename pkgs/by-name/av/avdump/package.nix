# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  buildDotnetModule,
  stdenv,
  fetchgit,
  dotnet-sdk_8,
  dotnet-runtime,
  libmediainfo,
  runCommand,
  _experimental-update-script-combinators,
  nix-update-script,
  writeShellScript,
}:

buildDotnetModule (finalAttrs: {
  pname = "avdump";
  version = "B9005-GitHubRelease-unstable-2024-03-10";

  src = fetchgit {
    url = "https://github.com/DvdKhl/AVDump3.git";
    rev = "7f3f7259e332b56d1f2dc6bb9f29bc4aa7e28c4a";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    hash = "sha256-5PxFI9+m83ZRdUM+vZ00Ag4pI/7OtnLwsSUK3bps8dU=";
  };

  avdumpNativeLib = stdenv.mkDerivation (cFinalAttrs: {
    inherit (finalAttrs)
      pname
      version
      src
      ;

    sourceRoot = "${cFinalAttrs.src.name}/AVDump3NativeLib";

    postPatch = ''
      substituteInPlace Makefile \
        --replace-fail 'CC = $(ARCH)-linux-gnu-gcc' \
          'CC = gcc'
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      mv AVDump3NativeLib.so $out/lib

      runHook postInstall
    '';
  });

  dotnet-sdk = dotnet-sdk_8;
  inherit dotnet-runtime;

  nugetDeps = ./deps.json;
  projectFile = "AVDump3CL/AVDump3CL.csproj";
  runtimeDeps = [
    finalAttrs.avdumpNativeLib
    (runCommand "MediaInfo" { } ''
      mkdir -p $out/lib
      ln -s ${libmediainfo}/lib/libmediainfo.so $out/lib/MediaInfo.so
    '')
  ];

  executables = [ "AVDump3CL" ];

  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (nix-update-script {
      extraArgs = [
        "-F"
        "--version=branch=NET8"
        "--src-only"
      ];
    })
    (writeShellScript "fetch-deps.sh" ''
      $(nix-build -A avdump.passthru.fetch-deps) "pkgs/by-name/av/avdump/deps.json"
    '')
  ];

  meta = {
    homepage = "https://github.com/DvdKhl/AVDump3";
    description = "Provide meta information about multi media files and their file hashes by selectable report formats";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
    platforms = lib.platforms.linux;
    mainProgram = "AVDump3CL";
  };
})
