{
  description = "Replicated Nix Profile Environment";

  inputs = {
    # Using the standard rolling unstable channel ensures it downloads successfully
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = pkgs.buildEnv {
        name = "my-profile";
        paths = with pkgs; [
          delta
          direnv
          docker-compose
          fresh-editor
          gh
          go
          gocryptfs
          herdr
          kind
          kopia
          kubectl
          mcporter
          neovim
          rclone
          starship
          stc
          syncthing
          tirith
        ];
      };
    };
}

