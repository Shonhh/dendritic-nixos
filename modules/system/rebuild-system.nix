{ ... }:
{
  flake.nixosModules.rebuild-system =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.system.rebuild-system;
      repositoryDirectory = config.mySystem.repository.directory;
    in
    {
      options.mySystem.system.rebuild-system.enable =
        lib.mkEnableOption "Explicit rebuild, formatting, update, and cleanup commands";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          (pkgs.writeShellApplication {
            name = "nrs";
            runtimeInputs = with pkgs; [
              coreutils
              findutils
              git
              jq
              nixfmt
              nix-output-monitor
              nvd
              libnotify
              nixos-rebuild
              nix
            ];
            text = ''
              repository_directory=${lib.escapeShellArg repositoryDirectory}
              flake_dir="$HOME/$repository_directory"
              host=${lib.escapeShellArg config.networking.hostName}
            ''
            + builtins.readFile ./scripts/nrs.sh;
          })
        ];
      };
    };
}
