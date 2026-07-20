{ pkgs, lib, ... }:
let
  # Gate packages that may not exist on older nixpkgs releases (26.05-darwin).
  maybe = name: lib.optionals (builtins.hasAttr name pkgs) [ (builtins.getAttr name pkgs) ];
  # Linux-only packages (unavailable/broken on x86_64-darwin)
  linuxOnly = lib.optionals pkgs.stdenv.isLinux (with pkgs; [
    calicoctl nerdctl opencode goofys
  ]);
in
{
  home.username = "jjo";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/jjo" else "/home/jjo";
  # HM 26.11 on nixpkgs 26.05-darwin triggers a version mismatch warning; safe to ignore.
  home.enableNixpkgsReleaseCheck = false;
  programs.home-manager.enable = true;
  home.packages =
    linuxOnly
    ++ maybe "herdr"
    ++ maybe "silver-searcher-ng"
    ++ (with pkgs; [
      # ── carried over from the original flake ──────────────────────────────
      delta                # was "gitDelta" in original; nixpkgs attr is `delta`
      direnv
      docker-compose
      fresh-editor
      gh
      go
      gocryptfs
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

      # ── brew leaves → nixpkgs ────────────────────────────────────────────
      ack
      actionlint
      age
      argo-workflows     # brew "argo" was renamed in nixpkgs
      asciinema
      awscli2            # awscli v2
      azure-cli
      bash-language-server
      buildkit           # buildctl / buildkitd
      cilium-cli
      cog
      colima
      lima               # colima dependency
      conftest
      devcontainer
      doctl
      drone-cli
      duckdb
      emscripten
      eslint
      eza
      fish
      fluxcd             # flux
      foundry
      fx
      git
      gitleaks
      glab
      glances
      gmailctl
      go-jsonnet
      gofumpt
      golangci-lint
      gopls
      goreleaser
      golines
      gotests
      python3Packages."huggingface-hub"  # brew hf (huggingface hub CLI)
      hugo
      jless
      jq
      jsonnet-bundler   # jb
      just
      k6
      k9s
      kompose
      krew
      kubebuilder
      kubecfg
      kubeconform
      kubo               # IPFS
      kustomize
      lazygit
      llmfit
      mage
      magic-wormhole
      markdownlint-cli
      opentofu
      openstackclient   # python-openstackclient
      pack              # buildpacks CLI
      pnpm
      prometheus-node-exporter  # node_exporter
      rancher           # rancher CLI
      recode
      rtk
      shfmt
      skills
      sshuttle
      stern
      tanka
      terraform-ls
      tfenv
      trufflehog
      ttyd
      vcluster
      wabt
      wasmtime
      yamllint
      yt-dlp            # youtube-dl is abandoned/insecure
      yq-go             # Go yq (brew yq)
      zizmor
      zk
      zoxide
      kubernetes-helm
      gcx
    ]);

  home.stateVersion = "25.05";
}
