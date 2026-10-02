{ inputs, nixosModules }:
{
  hostName,
  hardware,
  configuration,
}:
inputs.nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    hardware
    { networking.hostName = hostName; }
    configuration
  ]
  ++ builtins.attrValues nixosModules;
}
