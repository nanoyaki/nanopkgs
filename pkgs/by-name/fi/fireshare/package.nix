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
  version = "1.3.3-unstable-2026-01-04";

  src = fetchgit {
    url = "https://github.com/ShaneIsrael/fireshare.git";
    rev = "adfbb5c62a9dbb9ce67c8d5f82a004e6588c0883";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-IcXwWjuBMu5ztLp3gCZ2DzG1bdTL+L5K8UN3h7sZ/Ho=";
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
      hash = "sha256-+idyIRaQVgWMzpNrQ1YE8bbmHEGz47VGZtP5jHGM+Qw=";
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

  pythonRelaxDeps = [
    "click"
    "ffmpeg-python"
    "Flask"
    "Flask-Cors"
    "Flask-Login"
    "Flask-Migrate"
    "Flask-SQLAlchemy"
    "Flask-WTF"
    "future"
    "greenlet"
    "gunicorn"
    "importlib-metadata"
    "itsdangerous"
    "Jinja2"
    "MarkupSafe"
    "six"
    "SQLAlchemy"
    "Werkzeug"
    "WTForms"
    "zipp"
    "xxhash"
    "apscheduler"
    "python-ldap"
    "requests"
  ];

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
