{ ... }:

{
  flake.nixosModules.foot = { config, lib, pkgs, ... }:
  let
    cfg = config.mySystem.apps.foot;

    colors = config.lib.stylix.colors;
    fonts = config.stylix.fonts;
  in {
    options.mySystem.apps.foot.enable = lib.mkEnableOption "Foot Terminal Emulator";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.foot ];

      home-manager.users.shonh = {
      	stylix.targets.foot.enable = false;
	
	programs.foot = {
	  enable = true;

	  settings = {
	    main = {
              term = "xterm-256color";
              dpi-aware = lib.mkForce "yes";
	      font = "${fonts.monospace.name}:size=${toString fonts.sizes.terminal}";
            };

	    colors-dark = {
              background = colors.base00;
              foreground = colors.base05;
              regular0   = colors.base01; # black
              regular1   = colors.base08; # red
              regular2   = colors.base0B; # green
              regular3   = colors.base0A; # yellow
              regular4   = colors.base0D; # blue
              regular5   = colors.base0E; # magenta
              regular6   = colors.base0C; # cyan
              regular7   = colors.base05; # white
              bright0    = colors.base03; # bright black
              bright1    = colors.base08;
              bright2    = colors.base0B;
              bright3    = colors.base0A;
              bright4    = colors.base0D;
              bright5    = colors.base0E;
              bright6    = colors.base0C;
              bright7    = colors.base07;
            };
          };
	};
      };
    };
  };
}
