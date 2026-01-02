# SPDX-SnippetCopyrightText: 2023 Balthazar Patiachvili <ratcornu+programmation@skaven.org>
# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
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
  launcherJdk ? jdk,
  webui ? suwayomi-webui,
}:

let
  isLinux = lib.elem stdenv.hostPlatform.system lib.platforms.linux;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "suwayomi-server";
  version = "2.1.1867-unstable-2025-12-17";
  revision = "2038";

  src = fetchFromGitHub {
    owner = "Suwayomi";
    repo = "Suwayomi-Server";
    rev = "b97a808e7bb09e3faade22f76dbe60f2babebade";
    hash = "sha256-v1tjNda7PzwllT4jvotIYcQ4d/vpjk6idalYqC8KVm8=";
  };

  launcher = stdenvNoCC.mkDerivation (lFinalAttrs: {
    pname = "suwayomi-launcher";
    version = "f3eab6682e7fae1e5ab83a2add6d337fb3df80fc";

    src = fetchFromGitHub {
      owner = "Suwayomi";
      repo = "Suwayomi-Launcher";
      rev = "f3eab6682e7fae1e5ab83a2add6d337fb3df80fc";
      hash = "sha256-g4PEIQxjMXsOGDT2QWWzpeChPNM8w1ACecWxUBliJPA=";
    };

    postPatch = ''
      substituteInPlace src/main/kotlin/suwayomi/tachidesk/launcher/LauncherViewModel.kt \
        --replace-fail 'homeDir / "bin" / "Suwayomi-Server.jar"' \
          'java.io.File(java.lang.System.getProperty("suwayomi.server_jar")).toPath()' \
        --replace-fail '/usr/bin/java' '${lib.getExe' jdk "java"}' \
        --replace-fail '/usr/bin/electron' '${lib.getExe electron}'
    '';

    nativeBuildInputs = [ gradle_8 ];

    mitmCache = gradle_8.fetchDeps {
      pkg = lFinalAttrs;
      data = ./launcher/deps.json;
      useBwrap = false;
    };
    __darwinAllowLocalNetworking = true;

    gradleFlags = [ "-Dorg.gradle.java.home=${launcherJdk.home}" ];
    gradleBuildTask = "shadowJar";

    installPhase = ''
      runHook preInstall
      install -Dm644 build/Suwayomi-Launcher-*.jar $out/share/suwayomi-launcher/Suwayomi-Launcher.jar
      runHook postInstall
    '';
  });

  patches = [
    ./disable-download.patch
  ];

  postPatch = ''
    echo 'const val MainClass = "suwayomi.tachidesk.MainKt"
    val getTachideskVersion = { "v${lib.versions.majorMinor finalAttrs.version}.${finalAttrs.revision}" }
    val webUIRevisionTag = "r${webui.revision}"
    val getTachideskRevision = { "r${finalAttrs.revision}" }
    ' > buildSrc/src/main/kotlin/Constants.kt

    (cd ${webui} && zip -9 -r "$OLDPWD/server/src/main/resources/WebUI.zip" .)
  '';

  nativeBuildInputs = [
    zip
    makeWrapper
    gradle_8
    copyDesktopItems
  ];

  mitmCache = gradle_8.fetchDeps {
    pkg = finalAttrs;
    data = ./deps.json;
    useBwrap = false;
  };
  __darwinAllowLocalNetworking = true;

  gradleFlags = [
    "-Dorg.gradle.java.home=${jdk.home}"
    "-Dorg.gradle.jvmargs=-Xmx2G"
  ];
  gradleBuildTask = "shadowJar";

  postBuild = lib.optionalString isLinux ''
    gcc -fPIC \
      -lpthread \
      -I${jdk.home}/include \
      -I${jdk.home}/include/linux \
      -shared scripts/resources/catch_abort.c \
      -o catch_abort.so
  '';

  preInstall = lib.optionalString isLinux ''
    mkdir -p $out/lib
    cp catch_abort.so $out/lib
  '';

  installPhase = ''
    runHook preInstall

    builtJar="Suwayomi-Server-v${lib.versions.majorMinor finalAttrs.version}.${finalAttrs.revision}.jar"

    mkdir -p $out/{bin,share/suwayomi-server}
    cp "server/build/$builtJar" $out/share/suwayomi-server

    # Use nixpkgs suwayomi-webui and disable auto download and update
    makeWrapper ${lib.getExe jdk} $out/bin/tachidesk-server \
      --prefix LD_LIBRARY_PATH : "${
        (lib.optionalString isLinux "$out/lib:")
        + lib.makeLibraryPath [
          libappindicator
          glib
        ]
      }" \
      --add-flags "-Dsuwayomi.tachidesk.config.server.webUIFlavor=WebUI" \
      --add-flags "-Dsuwayomi.tachidesk.config.server.webUIChannel=BUNDLED" \
      --add-flags "-Dsuwayomi.tachidesk.config.server.webUIUpdateCheckInterval=0" \
      --add-flags "-Dsuwayomi.tachidesk.config.server.initialOpenInBrowserEnabled=false" \
      --add-flags "-Dsuwayomi.tachidesk.config.server.systemTrayEnabled=false" \
      --add-flags "-jar $out/share/suwayomi-server/$builtJar"

    makeWrapper ${lib.getExe jdk} $out/bin/suwayomi-launcher \
      --prefix LD_LIBRARY_PATH : "${
        (lib.optionalString isLinux "$out/lib:")
        + lib.makeLibraryPath [
          libappindicator
          glib
        ]
      }" \
      --add-flags "--add-exports=java.desktop/sun.awt=ALL-UNNAMED" \
      --add-flags '-Dsuwayomi.server_jar="$builtJar"' \
      --add-flags "-Dsuwayomi.tachidesk.config.server.webUIInterface=electron" \
      --add-flags '-Dsuwayomi.tachidesk.config.server.electronPath="${lib.getExe electron}"' \
      --add-flags "-jar ${finalAttrs.launcher}/share/suwayomi-launcher/Suwayomi-Launcher.jar"

    install -Dm644 server/src/main/resources/icon/faviconlogo-128.png \
      $out/share/icons/hicolor/128x128/apps/suwayomi-server.png

    runHook postInstall
  '';

  desktopItems = makeDesktopItem (
    with finalAttrs;

    {
      name = pname;
      desktopName = "Suwayomi Server";
      comment = "Free and open source manga reader";
      exec = "suwayomi-launcher";
      terminal = false;
      icon = pname;
      startupWMClass = pname;
      categories = [ "Utility" ];
    }
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
          "--subpackage=launcher"
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
})
