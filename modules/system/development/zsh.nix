{ ... }:

{
  flake.nixosModules.zsh =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.system.zsh;
    in
    {
      options.mySystem.system.zsh.enable = lib.mkEnableOption "Zsh Shell with Fish features";

      config = lib.mkIf cfg.enable {
        programs.zsh.enable = true;
        users.users.shonh.shell = pkgs.zsh;
        mySystem.system.starship.enable = true;

        home-manager.users.shonh = {
          programs.zsh = {
            enable = true;
            enableCompletion = true;

            # Faded predictions based on history
            autosuggestion.enable = true;

            # Coloring of valid/invalid commands
            syntaxHighlighting.enable = true;

            # UP arrow searches history based on what you already typed
            historySubstringSearch.enable = true;

            # Sensible defaults (Optional, but highly recommended for a modern feel)
            history = {
              size = 10000;
              save = 10000;
              ignoreDups = true; # Don't save duplicate commands to history
              share = true; # Share history across multiple open terminal windows
            };
          };
        };
      };
    };
}
