{ pkgs, lib, ... }:
{
  home.username = "jjo";
  home.homeDirectory = "/home/jjo";
  # Self-host: install the home-manager CLI so future switches don't need `nix run`.
  programs.home-manager.enable = true;
  home.packages = with pkgs;
    # 4 packages are Linux-only (unavailable or broken on x86_64-darwin)
    (lib.optionals pkgs.stdenv.isLinux [ calicoctl nerdctl opencode goofys ])
    ++ [
    # ── carried over from the original flake ──────────────────────────────
    delta                # was "gitDelta" in original nixpkgs attr
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
    silver-searcher-ng  # was the_silver_searcher/forked
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
  ];

  home.stateVersion = "25.05";
}
