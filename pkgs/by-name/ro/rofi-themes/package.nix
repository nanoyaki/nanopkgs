# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  stdenvNoCC,
  fetchgit,
  findutils,
  nix-update-script,

  background ? "1E2127FF",
  background-alt ? "282B31FF",
  foreground ? "FFFFFFFF",
  selected ? "61AFEFFF",
  active ? "98C379FF",
  urgent ? "E06C75FF",
}:

stdenvNoCC.mkDerivation {
  pname = "rofi-themes";
  version = "0-unstable-2025-07-26";

  src = fetchgit {
    url = "https://github.com/adi1090x/rofi.git";
    rev = "093c1a79f58daab358199c4246de50357e5bf462";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sparseCheckout = [ ];
    sha256 = "sha256-iUX0Quae06tGd7gDgXZo1B3KYgPHU+ADPBrowHlv02A=";
  };

  patchPhase = ''
    runHook prePatch

    for rasiFile in $(${lib.getExe findutils} . -name "*.rasi"); do
      substituteInPlace $rasiFile \
        --replace-quiet "@background-alt" "#${background-alt}" \
        --replace-quiet "@background" "#${background}" \
        --replace-quiet "@foreground" "#${foreground}" \
        --replace-quiet "@selected" "#${selected}" \
        --replace-quiet "@active" "#${active}" \
        --replace-quiet "@urgent" "#${urgent}" \
        --replace-quiet "@import                          \"shared/colors.rasi\"" ""
    done

    runHook postPatch
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/themes
    cp -r files/* $out/share/themes

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "-F"
      "--version=branch"
    ];
  };
}
