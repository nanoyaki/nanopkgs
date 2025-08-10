# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  python312Packages,
  buildNpmPackage,
  libffi,
  ffmpeg,
  openldap,
  cyrus_sasl,
  openssl,
  makeWrapper,
  sqlite,

  _sources,
}:

python312Packages.buildPythonApplication rec {
  inherit (_sources.fireshare) pname;
  version = lib.removePrefix "v" _sources.fireshare.version;
  pyproject = true;

  unpatchedSrc = _sources.fireshare.src;
  src = stdenvNoCC.mkDerivation {
    pname = "${pname}-src";
    inherit version;

    src = unpatchedSrc;
    patches = [ ./nixos-compat.patch ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r . $out

      runHook postInstall
    '';
  };
  sourceRoot = "${src.name}/app/server";

  frontend = buildNpmPackage {
    pname = "${pname}-frontend";
    inherit version src;
    sourceRoot = "${src.name}/app/client";

    npmDepsHash = "sha256-m+hZxDdJh9qKA2vYLiWzsFmHvoCrg1I0Wz4BUYve3ZQ=";

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

  meta = {
    description = "Share your game clips, videos, or other media via unique links.";
    homepage = "https://github.com/ShaneIsrael/fireshare";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ nanoyaki ];
    platforms = lib.platforms.linux;
    mainProgram = "fireshare";
  };
}
