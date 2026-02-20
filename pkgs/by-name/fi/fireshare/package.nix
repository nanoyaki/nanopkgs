# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  python312Packages,
  fetchgit,
  fetchNpmDeps,
  npmHooks,
  libffi,
  ffmpeg,
  openldap,
  cyrus_sasl,
  openssl,
  makeWrapper,
  sqlite,
  nodejs,
  nix-update-script,
}:

python312Packages.buildPythonApplication rec {
  pname = "fireshare";
  version = "1.4.2-unstable-2026-02-19";

  src = fetchgit {
    url = "https://github.com/ShaneIsrael/fireshare.git";
    rev = "72bde7c89d177ff125ab38bcd213989b25512713";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-CdJws+E+j8ZbLhQgHhWGsoY9RqeEW7BX7BeX+Im8kd4=";
  };

  pyproject = true;

  patches = [ ./nixos-compat.patch ];
  sourceRoot = "${src.name}/app/server";

  frontend = stdenvNoCC.mkDerivation {
    pname = "${pname}-frontend";
    inherit version src;
    sourceRoot = "${src.name}/app/client";

    nativeBuildInputs = [
      nodejs
      npmHooks.npmConfigHook
    ];

    npmDeps = fetchNpmDeps {
      name = "${pname}-${version}-npm-deps";
      inherit src;
      sourceRoot = "${src.name}/app/client";
      hash = "sha256-BBG2ckUgnU6GXxWu1LrZAjbMJua71FeDjGzGyBGVEx8=";
    };

    buildPhase = ''
      node_modules/react-scripts/bin/react-scripts.js build
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -ar build/* $out

      runHook postInstall
    '';
  };

  pythonRelaxDeps = true;

  build-system = with python312Packages; [ setuptools ];

  nativeBuildInputs = [ makeWrapper ];

  dependencies =
    (with python312Packages; [
      click
      ffmpeg-python
      flask
      flask-cors
      flask-login
      flask-migrate
      flask-sqlalchemy
      flask-wtf
      future
      greenlet
      gunicorn
      importlib-metadata
      itsdangerous
      jinja2
      markupsafe
      six
      sqlalchemy
      werkzeug
      wtforms
      zipp
      xxhash
      apscheduler
      python-ldap
      requests
      rapidfuzz
    ])
    ++ [
      ffmpeg
    ];

  buildInputs = [
    libffi
    openldap
    cyrus_sasl
    openssl
    sqlite
  ];

  postInstall = ''
    cd ../..

    mkdir -p $out/bin $out/share/fireshare $out/share/nginx
    cp app/nginx/prod.conf $out/share/nginx/nginx.conf
    ln -sf ${frontend} $out/share/fireshare/client
    cp -ar app/server $out/share/fireshare/server
    cp -ar migrations $out/share/fireshare/migrations

    makeWrapper ${lib.getExe python312Packages.gunicorn} $out/bin/fireshare-server \
      --add-flags "--chdir \"$out/share/fireshare/server\"" \
      --add-flags '"fireshare:create_app(init_schedule=True)"'

    makeWrapper ${lib.getExe python312Packages.flask} $out/bin/fireshare-upgrade \
      --add-flags "db upgrade -d \"$out/share/fireshare/migrations\""

    cd app/server
  '';

  postFixup = ''
    wrapProgram "$out/bin/fireshare-server" \
      --prefix PATH : "$program_PATH" \
      --prefix PYTHONPATH : "$program_PYTHONPATH"

    wrapProgram "$out/bin/fireshare-upgrade" \
      --prefix PATH : "$program_PATH" \
      --prefix PYTHONPATH : "$program_PYTHONPATH"
  '';

  # no tests available
  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "-F"
      "--version=branch"
      "-s"
      "frontend"
    ];
  };

  meta = {
    description = "Share your game clips, videos, or other media via unique links.";
    homepage = "https://github.com/ShaneIsrael/fireshare";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ nanoyaki ];
    platforms = lib.platforms.linux;
    mainProgram = "fireshare";
  };
}
