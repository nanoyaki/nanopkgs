# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  buildDotnetModule,
  stdenv,
  dotnet-sdk_8,
  dotnet-runtime,
  libmediainfo,
  runCommand,

  _sources,
}:

buildDotnetModule (finalAttrs: {
  inherit (_sources.avdump)
    pname
    version
    src
    date
    ;

  avdumpNativeLib = stdenv.mkDerivation (cFinalAttrs: {
    inherit (finalAttrs)
      pname
      version
      src
      date
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
})
