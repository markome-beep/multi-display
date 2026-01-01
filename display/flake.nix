{
  description = "Orange Pi Zero";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Hardware support for OPi Zero 3
    opi-zero3.url = "github:arcayr/orangepizero3-nix";
  };

  outputs = { self, nixpkgs, opi-zero3, ... }: {
    nixosConfigurations.orangepi = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        opi-zero3.nixosModules.default
        ./configuration.nix
      ];
    };
  };
}
