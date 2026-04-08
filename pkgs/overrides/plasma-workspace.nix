# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: prev: {
  kdePackages = prev.kdePackages.overrideScope (
    _: kdePrev: {
      # https://old.reddit.com/r/NixOS/comments/1pdtc3v/kde_plasma_is_slow_compared_to_any_other_distro/
      # https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-3194531220
      plasma-workspace =
        let
          # a helper package that merges all the XDG_DATA_DIRS into a single directory
          xdgdataPkg = final.stdenv.mkDerivation {
            name = "${kdePrev.plasma-workspace.name}-xdgdata";
            buildInputs = [ kdePrev.plasma-workspace ];
            dontUnpack = true;
            dontFixup = true;
            dontWrapQtApps = true;
            installPhase = ''
              mkdir -p $out/share
              ( IFS=:
                for DIR in $XDG_DATA_DIRS; do
                  if [[ -d "$DIR" ]]; then
                    ${prev.lib.getExe prev.lndir} -silent "$DIR" $out
                  fi
                done
              )
            '';
          };
        in
        # undo the XDG_DATA_DIRS injection that is usually done in the qt wrapper
        # script and instead inject the path of the above helper package
        kdePrev.plasma-workspace.overrideAttrs {
          preFixup = ''
            for index in "''${!qtWrapperArgs[@]}"; do
              if [[ ''${qtWrapperArgs[$((index+0))]} == "--prefix" ]] && [[ ''${qtWrapperArgs[$((index+1))]} == "XDG_DATA_DIRS" ]]; then
                unset -v "qtWrapperArgs[$((index+0))]"
                unset -v "qtWrapperArgs[$((index+1))]"
                unset -v "qtWrapperArgs[$((index+2))]"
                unset -v "qtWrapperArgs[$((index+3))]"
              fi
            done
            qtWrapperArgs=("''${qtWrapperArgs[@]}")
            qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdataPkg}/share")
            qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
          '';
        };
    }
  );

  plasma-workspace-xdg-fixed = final.kdePackages.plasma-workspace;
}
