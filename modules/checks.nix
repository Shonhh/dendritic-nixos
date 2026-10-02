{ config, lib, ... }:
let
  source = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.fileFilter (file: file.hasExt "nix" || file.hasExt "sh") ../.;
  };

  # Plain strings force evaluation without adding host builds as dependencies.
  hostDerivations = lib.mapAttrs (
    _: host: builtins.unsafeDiscardStringContext host.config.system.build.toplevel.drvPath
  ) config.flake.nixosConfigurations;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks = {
        host-evaluation = pkgs.writeText "host-derivations.json" (builtins.toJSON hostDerivations);

        formatting =
          pkgs.runCommand "check-nix-formatting"
            {
              nativeBuildInputs = [
                pkgs.findutils
                pkgs.nixfmt
              ];
            }
            ''
              set -euo pipefail
              cd ${source}

              find . -type f -name '*.nix' -print0 |
                xargs -0 -r nixfmt --check

              touch "$out"
            '';

        shell-scripts =
          pkgs.runCommand "check-shell-scripts"
            {
              nativeBuildInputs = [
                pkgs.findutils
                pkgs.shellcheck
              ];
            }
            ''
              set -euo pipefail
              cd ${source}

              find . -type f -name '*.sh' -print0 |
                xargs -0 -r shellcheck --shell=bash

              touch "$out"
            '';
      };
    };
}
