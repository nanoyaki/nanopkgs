# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  perSystem =
    {
      lib,
      pkgs,
      self',
      ...
    }:

    let
      inherit (lib)
        attrNames
        concatStrings
        removeSuffix
        optionalString
        stringLength
        substring
        ;
    in

    {
      apps.update-readme = {
        type = "app";
        program = pkgs.writeShellApplication (
          let
            output = pkgs.replaceVars ./README.template.md {
              availablepkgs = removeSuffix "\n" (
                concatStrings (
                  map (
                    package:
                    let
                      version = optionalString (self'.packages.${package} ? version) (
                        let
                          inherit (self'.packages.${package}) version;
                          shortened = if (stringLength version) == 40 then substring 0 7 version else version;
                        in
                        " -> `${shortened}`"
                      );
                    in
                    "- `${package}`${version}\n"
                  ) (attrNames self'.packages)
                )
              );
            };
          in
          {
            name = "update-readme";
            text = ''
              install -m644 ${output} README.md
            '';

            derivationArgs = {
              doCheck = true;
              nativeCheckInputs = [ pkgs.diffutils ];
            };
          }
        );

        meta.description = ''
          Update README.md with available packages.
        '';
      };
    };
}
