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

  _sources,
}:

python312Packages.buildPythonApplication rec {
  inherit (_sources.fireshare) pname version;
  pyproject = true;

  unpatchedSrc = _sources.fireshare.src;
  src = stdenvNoCC.mkDerivation {
    pname = "${pname}-src";
    inherit version;

    src = unpatchedSrc;

    postPatch = ''
      substituteInPlace app/server/requirements.txt \
        --replace-fail "Flask-Cors==3.0.10" "Flask-Cors" \
        --replace-fail "==" ">="
    '';

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

  dependencies = with python312Packages; [
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
  ];

  buildInputs = [
    libffi
    ffmpeg
    openldap
    cyrus_sasl
    openssl
  ];

  postPatch = ''
    substituteInPlace fireshare/main.py \
      --replace-fail "before_app_first_request" "before_app_request"
  '';

  postInstall = ''
    cd ../..

    mkdir -p $out/bin $out/share/fireshare $out/share/nginx
    cp app/nginx/prod.conf $out/share/nginx/nginx.conf
    ln -sf ${frontend} $out/share/fireshare/client
    cp -ar app/server $out/share/fireshare/server
    mv $out/bin/fireshare $out/bin/fireshare-cli

    makeWrapper ${lib.getExe python312Packages.gunicorn} $out/bin/fireshare-server \
      --add-flags "--chdir \"$out/share/fireshare/server\"" \
      --add-flags '"fireshare:create_app(init_schedule=True)"'

    cd app/server
  '';

  postFixup = ''
    wrapProgram "$out/bin/fireshare-server" \
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
    mainProgram = "fireshare-cli";
  };
}
