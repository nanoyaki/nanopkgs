# SPDX-SnippetCopyrightText: 2023 Balthazar Patiachvili <ratcornu+programmation@skaven.org>
# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  fetchgit,
  zip,
  makeWrapper,
  gradle_8,
  copyDesktopItems,
  glib,
  libappindicator,
  jdk21_headless,
  suwayomi-webui,
  _experimental-update-script-combinators,
  nix-update-script,
  writeShellScript,
  nixosTests,
  electron,
  makeDesktopItem,

  jdk ? jdk21_headless,
  webui ? suwayomi-webui,
  asApplication ? false,
}:

let
  self = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "suwayomi-server";
    version = "2.1.1867-unstable-2026-01-11";
    revision = "2049";

    src = fetchgit {
      url = "https://github.com/Suwayomi/Suwayomi-Server.git";
      rev = "02da884f176e51c9ced8a95fa0954b4906522de7";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-M1S40zp4/zlixMhXD/HhfJtIE3UlNk4cVeYoKCOrYi8=";
    };

    patches = [
      ./disable-download.patch
    ];

    postPatch = ''
      echo 'const val MainClass = "suwayomi.tachidesk.MainKt"
      val getTachideskVersion = { "v${lib.versions.majorMinor finalAttrs.version}.${finalAttrs.revision}" }
      val webUIRevisionTag = "r${webui.revision}"
      val getTachideskRevision = { "r${finalAttrs.revision}" }
      ' > buildSrc/src/main/kotlin/Constants.kt

      zip -9 -r server/src/main/resources/WebUI.zip ${webui}
    '';

    nativeBuildInputs = [
      zip
      makeWrapper
      gradle_8
    ]
    ++ lib.optional asApplication copyDesktopItems;

    mitmCache = gradle_8.fetchDeps {
      pkg = self;
      data = ./deps.json;
      useBwrap = false;
    };

    gradleFlags = [
      "-Dorg.gradle.java.home=${jdk}"
      "-Dorg.gradle.jvmargs=-Xmx2G"
    ];

    gradleBuildTask = "shadowJar";

    installPhase = ''
      runHook preInstall

      builtJar="Suwayomi-Server-v${lib.versions.majorMinor finalAttrs.version}.${finalAttrs.revision}.jar"

      mkdir -p $out/{bin,share/suwayomi-server,share/icons/hicolor/128x128/apps}
      cp "server/build/$builtJar" $out/share/suwayomi-server

      # Use nixpkgs suwayomi-webui and disable auto download and update
      makeWrapper ${lib.getExe jdk} $out/bin/tachidesk-server \
        --add-flags "-Dsuwayomi.tachidesk.config.server.webUIFlavor=WebUI" \
        --add-flags "-Dsuwayomi.tachidesk.config.server.webUIChannel=BUNDLED" \
        --add-flags "-Dsuwayomi.tachidesk.config.server.webUIUpdateCheckInterval=0" \
    ''
    + lib.optionalString asApplication ''
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libappindicator
          glib
        ]
      }" \
      --add-flags "-Dsuwayomi.tachidesk.config.server.webUIInterface=electron" \
      --add-flags '-Dsuwayomi.tachidesk.config.server.electronPath="${lib.getExe electron}"' \
    ''
    + lib.optionalString (!asApplication) ''
      --add-flags "-Dsuwayomi.tachidesk.config.server.initialOpenInBrowserEnabled=false" \
      --add-flags "-Dsuwayomi.tachidesk.config.server.systemTrayEnabled=false" \
    ''
    + ''
        --add-flags "-jar $out/share/suwayomi-server/$builtJar"

      install -m644 server/src/main/resources/icon/faviconlogo-128.png \
        $out/share/icons/hicolor/128x128/apps/suwayomi-server.png

      runHook postInstall
    '';

    desktopItems = lib.optional asApplication (
      makeDesktopItem (
        with finalAttrs;

        {
          name = pname;
          desktopName = "Suwayomi Server";
          comment = "Free and open source manga reader";
          exec = meta.mainProgram;
          terminal = false;
          icon = pname;
          startupWMClass = pname;
          categories = [ "Utility" ];
        }
      )
    );

    passthru = {
      updateScript = _experimental-update-script-combinators.sequence [
        [
          ./update-rev.sh
          finalAttrs.src.rev
          "pkgs/overrides/suwayomi-server/package.nix"
        ]
        (nix-update-script {
          extraArgs = [
            "-F"
            "--version=branch"
          ];
        })
        (writeShellScript "update-deps.sh" ''
          $(nix-build -A suwayomi-server.mitmCache.updateScript)
        '')
      ];

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
        nanoyaki
        ratcornu
      ];
      mainProgram = "tachidesk-server";
    };
  });
in
self
