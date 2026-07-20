{
  description = "Replicated Nix Profile Environment (brew → nix migration)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Darwin (Intel Mac) needs nixpkgs-26.05-darwin — the last release supporting x86_64-darwin.
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, nixpkgs-darwin, home-manager }:
    let
      mkHM = pkgs': home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs';
        modules = [ ./home.nix ];
      };
    in {
      homeConfigurations = {
        "jjo@x86_64-linux" = mkHM nixpkgs.legacyPackages.x86_64-linux;
        "jjo@mac"          = mkHM nixpkgs-darwin.legacyPackages.x86_64-darwin;
      };
    };
}
