{
  description = "Replicated Nix Profile Environment (brew → nix migration)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Darwin (Intel Mac) needs nixpkgs-26.05-darwin — the last release supporting x86_64-darwin.
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    home-manager.url = "github:nix-community/home-manager";
    # home-manager may evaluate its own internal modules; let it use its own pinned nixpkgs
    # (no follow) to avoid cross-platform version conflicts.
  };

  outputs = { self, nixpkgs, nixpkgs-darwin, home-manager }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      hf = pkgs.python3Packages.huggingface-hub;
      # mkHM builds a config for a given package set (system-appropriate nixpkgs)
      mkHM = pkgs': home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs';
        modules = [ ./home.nix ];
      };
    in {
      packages.${system} = rec {
        default = pkgs.buildEnv {
          name = "my-profile";
          paths = with pkgs; [
            delta direnv docker-compose fresh-editor gh go gocryptfs herdr
            kind kopia kubectl mcporter neovim rclone starship stc syncthing tirith
            ack actionlint age argo-workflows asciinema awscli2 azure-cli
            bash-language-server buildkit calicoctl cilium-cli cog colima lima conftest
            devcontainer doctl drone-cli duckdb emscripten eslint eza fish
            fluxcd foundry fx git gitleaks glab glances gmailctl go-jsonnet
            gofumpt golangci-lint gopls goreleaser golines goofys gotests
            hf hugo jless jq jsonnet-bundler just k6 k9s kompose krew kubebuilder
            kubecfg kubeconform kubo kustomize lazygit llmfit mage magic-wormhole
            markdownlint-cli nerdctl opencode opentofu openstackclient pnpm
            prometheus-node-exporter rancher recode rtk shfmt skills sshuttle stern
            tanka terraform-ls tfenv silver-searcher-ng trufflehog ttyd vcluster wabt
            wasmtime yamllint yt-dlp (lib.hiPrio yq-go) zizmor zk zoxide kubernetes-helm
          ];
        };
        overlays-todo = pkgs.buildEnv {
          name = "my-profile-overlays-todo";
          paths = [ ];
        };
      };
      homeConfigurations = {
        "jjo@x86_64-linux" = mkHM nixpkgs.legacyPackages.x86_64-linux;
        "jjo@mac"          = mkHM nixpkgs-darwin.legacyPackages.x86_64-darwin;
      };
    };
}
