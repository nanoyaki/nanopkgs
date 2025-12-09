# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  # lib,
  python312,
  fetchFromGitHub,
  fetchPypi,
  # pkg-config,
  # icu,
  # sqlite,
  nltk-data,
  nix-update-script,
  ...
}:

let
  packageOverrides = final: prev: {
    click = prev.click.overridePythonAttrs rec {
      version = "8.1.8";

      src = fetchFromGitHub {
        owner = "pallets";
        repo = "click";
        tag = version;
        hash = "sha256-pAAqf8jZbDfVZUoltwIFpov/1ys6HSYMyw3WV2qcE/M=";
      };
    };

    dbscan1d = final.buildPythonPackage rec {
      pname = "dbscan1d";
      version = "0.2.2";
      pyproject = true;

      src = fetchPypi {
        inherit version;
        pname = "dbscan1d";
        hash = "sha256-lgA4T3sJvU9db/A03/sA+exeP2XoqX7pWiueyT7ZahI=";
      };

      nativeBuildInputs = [ final.setuptools-scm ];
      propagatedBuildInputs = with final; [ numpy ];
    };

    flask-apscheduler = final.buildPythonPackage rec {
      pname = "Flask-APScheduler";
      version = "1.13.1";
      pyproject = true;

      src = fetchPypi {
        inherit version;
        pname = "Flask-APScheduler";
        hash = "sha256-uSmEbwJvszm3Y2Cw5Px12ni3XG0IYlcVvQ03lJvWB9o=";
      };

      propagatedBuildInputs = with final; [
        flask
        apscheduler
        python-dateutil
      ];
    };

    # mlextend =
  };

  python3Packages = (python312.override { inherit packageOverrides; }).pkgs;
in

python3Packages.buildPythonApplication rec {
  pname = "kitchenowl-backend";
  version = "0.7.4-unstable-2025-12-06";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "TomBursch";
    repo = "Kitchenowl";
    rev = "c26188f5926a70cb6d899fdcf29ca2c5e6480484";
    hash = "sha256-rZn2nty/O2soYX9PJYlZqCtb0NjsfjMZTsxHAWLVkXA=";
  };

  sourceRoot = "${src.name}/backend";

  patches = [ ./no-basicauth.patch ];
  postPatch = ''
    rm Dockerfile
  '';

  installPhase = ''
    mkdir -p $out/opt/kitchenowl
    cp -r . $out/opt/kitchenowl
  '';

  propagatedBuildInputs = with python3Packages; [
    aiohappyeyeballs
    aiohttp
    aiosignal
    alembic
    amqp
    annotated-types
    anyio
    apispec
    appdirs
    apscheduler
    attrs
    autopep8
    bcrypt
    beautifulsoup4
    bidict
    billiard
    black
    blinker
    blurhash-python
    celery
    certifi
    cffi
    charset-normalizer
    click
    click-didyoumean
    click-plugins
    click-repl
    contourpy
    coverage
    cryptography
    cycler
    dbscan1d
    defusedxml
    extruct
    filelock
    flake8
    flask
    flask-apscheduler
    #flask-basicauth
    flask-bcrypt
    flask-jwt-extended
    flask-migrate
    flask-socketio
    flask-sqlalchemy
    flexcache
    flexparser
    fonttools
    frozenlist
    fsspec
    future
    gevent
    greenlet
    h11
    html-text
    html5lib
    httpcore
    httpx
    huggingface-hub
    importlib-metadata
    idna
    ingredient-parser-nlp
    iniconfig
    isodate
    itsdangerous
    jinja2
    joblib
    # jitter
    jsonschema
    jsonschema-spec
    jstyleson
    kiwisolver
    kombu
    lark
    litellm
    lxml
    lxml-html-clean
    mako
    markupsafe
    marshmallow
    matplotlib
    mccabe
    mf2py
    mlextend
    multidict
    mypy-extensions
    nltk
    numpy
    oic
    openai
    packaging
    pandas
    pathspec
    pillow
    pint
    platformdirs
    pluggy
    prometheus-client
    prometheus-flask-exporter
    prompt-toolkit
    propcache
    psycopg2
    py
    pycodestyle
    pycparser
    pycryptodomex
    pydantic
    pydantic-settings
    pyflakes
    pyjwkest
    pyjwt
    pyparsing
    pyrdfa3
    pytest
    python-crfsuite
    python-dateutil
    python-dotenv
    python-editor
    python-engineio
    python-socketio
    pytz
    pytz-deprecation-shim
    pyyaml
    rdflib
    #rdflib-jsonld
    recipe-scrapers
    referencing
    regex
    requests
    rpds-py
    scikit-learn
    scipy
    setuptools-scm
    simple-websocket
    six
    soupsieve
    sqlalchemy
    sqlite-icu
    threadpoolctl
    tiktoken
    tokenizers
    toml
    tomli
    tqdm
    typed-ast
    types-beautifulsoup4
    types-html5lib
    types-requests
    types-urllib3
    typing-extensions
    tzdata
    tzlocal
    urllib3
    # uwsgi
    # uwsgi-tools
    vine
    w3lib
    wcwidth
    webencodings
    werkzeug
    wsproto
    yarl
    zipp
    zope-event
    zope-interface
  ];

  passthru = {
    pythonPath = python3Packages.makePythonPath propagatedBuildInputs;
    nltkData = with nltk-data; [ averaged_perceptron_tagger ];
    inherit python3Packages;

    updateScript = nix-update-script {
      extraArgs = [
        "-F"
        "--version"
        "branch"
        "-s"
        "passthru.python3Packages.dbscan1d"
      ];
    };
  };
}
