{ ... }:
{
  flake.nixosModules.repository = { lib, ... }: {
    options.mySystem.repository.directory = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "Repository directory relative to the user's home directory.";
    };
  };
}
