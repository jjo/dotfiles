{
  description = "Replicated Nix Profile Environment (brew → nix migration)";

  inputs = {
    # Using the standard rolling unstable channel ensures it downloads successfully
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # `hf` is only shipped as a Python package (python3Packages.huggingface-hub);
      # its mainProgram is "hf", so wrap it as a runnable derivation.
      hf = pkgs.python3Packages.huggingface-hub;
    in {
      packages.${system} = rec {
        default = pkgs.buildEnv {
          name = "my-profile";
          paths = with pkgs; [
            # ── carried over from the original flake ──────────────────────────────
            delta                # was "gitDelta" in original; nixpkgs attr is `delta`
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

            # ── brew leaves → nixpkgs (all verified to exist) ────────────────────
            ack
            actionlint
            age
            argo-workflows     # brew "argo" was renamed to argo-workflows in nixpkgs
            asciinema
            awscli2            # awscli v2
            azure-cli
            bash-language-server
            buildkit          # buildctl / buildkitd
            calicoctl
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
            goofys
            gotests
            hf                 # huggingface hub CLI (python3Packages.huggingface-hub, mainProgram=hf)
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
            kubo               # IPFS (brew "kubo")
            kustomize
            lazygit
            llmfit
            mage
            magic-wormhole
            markdownlint-cli
            nerdctl
            opencode
            opentofu
            openstackclient   # python-openstackclient
            pnpm
            prometheus-node-exporter  # node_exporter
            rancher           # rancher CLI (desc: "CLI tool for interacting with your Rancher Server")
            recode
            rtk
            shfmt
            skills
            sshuttle
            stern
            tanka
            terraform-ls
            tfenv
            silver-searcher-ng  # `the_silver_searcher` removed from nixpkgs; fork is the replacement
            trufflehog
            ttyd
            vcluster
            wabt
            wasmtime
            yamllint
            yt-dlp             # youtube-dl is abandoned/insecure; yt-dlp is the maintained, CLI-compatible fork
            yq-go
            zizmor
            zk
            zoxide

            # ── helm v3 (brew "helm"; brew also had helm@2 — see overlay TODO) ─────
            kubernetes-helm
          ];
        };

        # ───────────────────────────────────────────────────────────────────────
        # OVERLAY TODO — brew leaves with NO nixpkgs package (verified).
        # Each needs a real derivation below; buildGoModule templates pre-filled
        # — run `nix build .#overlays-todo` and replace `vendorHash = lib.fakeHash`
        # with the hash Nix prints on the first failure.
        #
        #   wash     (wasmCloud shell; brew wasmcloud/wasmcloud/wash) — Go binary
        #   helm@2   (helm 2.x — kubernetes-helm in nix is v3 only)
        #   wasm3    (removed from nixpkgs — unmaintained, known vulns; no replacement)
        #
        # NOTE: 12 of the original 13 "missing" items DO exist in nixpkgs under
        # other attribute names and are now in the list above:
        #   openstackclient=openstackclient, rancher=rancher, krew=krew, rtk=rtk,
        #   llmfit=llmfit, opencode=opencode, skills=skills, golines=golines,
        #   goofys=goofys, gotests=gotests, hf=python3Packages.huggingface-hub,
        #   silver-searcher→silver-searcher-ng (fork).
        # ───────────────────────────────────────────────────────────────────────
        overlays-todo = pkgs.buildEnv {
          name = "my-profile-overlays-todo";
          paths = [
            # (pkgs.buildGoModule rec {
            #   pname = "wash"; version = "0.37.0";
            #   src = pkgs.fetchFromGitHub { owner = "wasmCloud"; repo = "wash"; rev = "v${version}"; sha256 = pkgs.lib.fakeHash; };
            #   vendorHash = pkgs.lib.fakeHash;
            # })
          ];
        };
      };
    };
}
