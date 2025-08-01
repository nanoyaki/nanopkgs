# SPDX-SnippetCopyrightText: 2023 Balthazar Patiachvili <ratcornu+programmation@skaven.org>
# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  replaceVars,
  makeWrapper,
  gradle_8,
  jdk21_headless,
  jdk ? jdk21_headless,
  suwayomi-webui,
  webui ? suwayomi-webui,
  nix-update-script,
  nixosTests,
  asApplication ? false,
  electron,

  _sources,
  _versions,
}:

let
  self = stdenvNoCC.mkDerivation (finalAttrs: {
    inherit (_sources.suwayomi-server) pname src;
    version =
      (lib.concatStringsSep "." (
        lib.take 2 (lib.splitString "." _versions.suwayomi-server.currentVersion)
      ))
      + ".${_versions.suwayomi-server.revision}";

    patches = [
      (replaceVars ./version.patch {
        majorMinor = lib.concatStringsSep "." (
          lib.take 2 (lib.splitString "." _versions.suwayomi-server.currentVersion)
        );
        inherit (finalAttrs) version;
        previousWebuiRevision = _versions.suwayomi-server.webuiRevision;
        webuiRevision = webui.revision;
        inherit (_versions.suwayomi-server) revision;
      })
    ];

    postPatch = ''
      install -m644 ${webui}/share/WebUI.zip server/src/main/resources
    '';

    nativeBuildInputs = [
      makeWrapper
      gradle_8
    ];

    mitmCache = gradle_8.fetchDeps {
      pkg = self;
      data = ./deps.json;
    };
    gradleBuildTask = "shadowJar";
    gradleFlags = [
      "-Dorg.gradle.java.home=${jdk}"
      "-Dorg.gradle.daemon=false"
      "-Dorg.gradle.jvmargs=-Xmx5120m"

      "-Dkotlin.incremental=false"
      "-Dkotlin.compiler.execution.strategy=in-process"
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{bin,share/suwayomi-server}
      cp server/build/Suwayomi-Server-v${finalAttrs.version}.jar $out/share/suwayomi-server

      makeWrapper ${lib.getExe jdk} $out/bin/tachidesk-server \
        ${
          if asApplication then
            ''
              --add-flags "-Dsuwayomi.tachidesk.config.server.webUIInterface=electron" \
              --add-flags '-Dsuwayomi.tachidesk.config.server.electronPath="${lib.getExe electron}"' \
            ''
          else
            ''
              --add-flags "-Dsuwayomi.tachidesk.config.server.initialOpenInBrowserEnabled=false" \
            ''
        } \
        --add-flags "-jar $out/share/suwayomi-server/Suwayomi-Server-v${finalAttrs.version}.jar"

      runHook postInstall
    '';

    passthru = {
      updateScript = nix-update-script { extraArgs = [ "--subpackage mitmCache" ]; };
      tests = {
        suwayomi-server-with-auth = nixosTests.suwayomi-server.with-auth;
        suwayomi-server-without-auth = nixosTests.suwayomi-server.without-auth;
      };
    };

    meta = {
      description = "Free and open source manga reader server that runs extensions built for Mihon (Tachiyomi)";
      longDescription = ''
        Suwayomi is an independent Mihon (Tachiyomi) compatible software and is not a Fork of Mihon (Tachiyomi).

        Suwayomi-Server is as multi-platform as you can get.
        Any platform that runs java and/or has a modern browser can run it.
        This includes Windows, Linux, macOS, chrome OS, etc.
      '';
      homepage = "https://github.com/Suwayomi/Suwayomi-Server";
      downloadPage = "https://github.com/Suwayomi/Suwayomi-Server/releases";
      changelog = "https://github.com/Suwayomi/Suwayomi-Server/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.mpl20;
      inherit (jdk.meta) platforms;
      sourceProvenance = with lib.sourceTypes; [
        fromSource
        binaryBytecode
      ];
      maintainers = with lib.maintainers; [
        ratcornu
        nanoyaki
      ];
      mainProgram = "tachidesk-server";
    };
  });
in
self
