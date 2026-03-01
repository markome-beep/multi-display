{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        # iface = "enp3s0f4u2c2";
        # ip = "192.168.0.150/24";
      in {
        devShells.default = pkgs.mkShell {
          name = "multi-disp";

          buildInputs = with pkgs; [
            bashInteractive

            arp-scan-rs
            nmap
            ntp

            go
            wails
            gtk3
            webkitgtk_6_0
            usbimager
            p7zip

            mpv
            yt-dlp
            ffmpeg

            nodejs_25
          ];

          shellHook = with pkgs; ''
      export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS;
      export GIO_MODULE_DIR="${pkgs.glib-networking}/lib/gio/modules/";
          '';

        };
      }
    );
}
