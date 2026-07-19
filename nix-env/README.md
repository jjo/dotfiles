# nix-env runbook

Home-manager + flakes, declarative user environment. Shared across Linux (x86_64-linux)
and macOS Intel (x86_64-darwin). One source of truth: `home.nix` + `flake.nix`.

## Ground rules

- Edit `home.nix` → `git add` → `home-manager switch`. That's the entire daily loop.
- Never use `nix profile install` on boxes migrated to home-manager — that's the
  bug-class we hit before (collisions, silent no-ops on re-add).
- Commit `flake.lock` alongside any config change so machines stay in sync.
- `home-manager switch` is idempotent and atomic; failed builds don't disturb the
  running generation.

## 1) Add / remove a package

All edits happen in `home.nix`'s `home.packages = [ ... ]` list.

Add: insert `pkgname` (respect existing grouping).
Remove: delete the line.

```
cd ~/nix-env
git add home.nix                                  # flake reads only git-tracked files
home-manager switch --flake .#jjo@x86_64-linux    # builds + activates; idempotent
```

On the Mac: `--flake .#jjo@x86_64-darwin`.

`switch` rebuilds and atomically swaps the generation. If a build fails, the
current generation is untouched — nothing breaks.

Roll back a bad switch:
```
home-manager generations                          # list generations w/ timestamps
home-manager switch --switch-generation <N>       # rollback by number
```

## 2) Upgrade all packages

Packages come from the `nixpkgs` flake input pinned in `flake.lock`. Upgrading =
bumping the lock, then switching.

```
cd ~/nix-env
nix flake update                                  # re-pins nixpkgs AND home-manager
home-manager switch --flake .#jjo@x86_64-linux
```

`nix flake update` bumps to the newest commit of `nixos-unstable`. Home-manager
follows because `home-manager.inputs.nixpkgs.follows = "nixpkgs"`.

Upgrade only nixpkgs (not home-manager):
```
nix flake lock --update-input nixpkgs
```

Pin to a specific revision (debugging):
```
nix flake lock --override-input nixpkgs github:nixos/nixpkgs/<sha>
```

Garbage-collect old generations (frees disk; keeps current):
```
home-manager expire-generations "-30 days"        # mark older than 30d as expired
nix-collect-garbage -d                            # delete; -d also removes old gens
```

Conservative (keeps everything live):
```
nix-collect-garbage                               # only removes unreachable store paths
```

## 3) Day 2 ops

### a) See what's currently installed (declared vs actual)
```
nix profile list                                  # current profile contents
home-manager packages                              # what's declared in the config
```

### b) Diff between two generations
```
nix store diff-closures ~/.local/state/nix/profiles/home-manager \
                       ~/.local/state/nix/profiles/home-manager-links/<older>
```

### c) Inspect a package's version/source
```
nix eval .#homeConfigurations."jjo@x86_64-linux".config.home.packages \
  --apply 'p: map (x: {n=x.name; v=x.version;}) p' | jq
nix flake metadata github:nixos/nixpkgs/$(jq -r .nodes.nixpkgs.locked.rev flake.lock)
```

### d) Shell into an ad-hoc environment WITHOUT installing
```
nix shell nixpkgs#<pkg1> nixpkgs#<pkg2>            # temporary, no profile mutation
nix run nixpkgs#<pkg>                              # run once, no install
```

### e) Edit a package's nix expression locally (overlay pattern)
Drop into `overlays/nixpkgs.nix`:
```nix
{ pkgs, ... }: {
  nixpkgs.overlays = [
    (self: super: {
      <pkg> = super.<pkg>.overrideAttrs (o: {
        patches = (o.patches or []) ++ [ ./my.patch ];
      });
    })
  ];
}
```
Add `./overlays/nixpkgs.nix` to `modules` in the flake's `mkHM`.

### f) Two-machine sync (local + o.jjo.us.to + Mac)
Same repo on all boxes. Edit locally → commit → push. On each remote:
```
cd ~/nix-env && git pull && home-manager switch --flake .#jjo@x86_64-linux
```

Host-specific packages via a `hosts/<hostname>.nix` module:
```nix
# flake.nix
homeConfigurations."jjo@<host>" = mkHM "x86_64-linux" [ ./hosts/<host>.nix ];
```
```nix
# hosts/<host>.nix
{ pkgs, ... }: { home.packages = with pkgs; [ <host-specific> ]; }
```

### g) macOS bridging (casks not in nixpkgs)
For full declarative casks use `nix-darwin`. For one-offs, keep `brew install` for
GUI apps not in nixpkgs. To avoid collisions, don't put brew-installed CLI tools
in `home.packages`.

### h) Running services (Linux only — systemd user units)
```nix
# home.nix
services.syncthing.enable = true;                  # declarative systemd user unit
```
Same `switch` applies. macOS uses `launchd` agents (`launchd.agents.<name>`).

### i) Verify nothing dropped after `switch`
```
home-manager switch --flake .#jjo@x86_64-linux --verbose 2>&1 | grep -E 'removed|added|changed'
```
List of removed/added/changed packages prints; verify nothing unexpected was dropped.

### j) Preview before switching
```
home-manager build --flake .#jjo@x86_64-linux     # build only; doesn't activate
nvd diff ~/.local/state/nix/profiles/home-manager ./result
# then if happy:
home-manager switch --flake .#jjo@x86_64-linux
```
(`nvd` is a tool: `nix profile install nixpkgs#nvd` once.)

### k) Periodic health check
```
nix flake check                                   # validate the flake without building
nix flake show                                    # see all outputs
```

## Reference: files in this repo

- `flake.nix`         — inputs (nixpkgs + home-manager), `mkHM` helper, outputs
- `flake.lock`        — pinned revisions (commit alongside config changes)
- `home.nix`          — shared module: `home.packages` + `home.stateVersion`
- `overlays/`         — (optional) local package overrides
- `hosts/`            — (optional) per-host specific packages

## Platform notes

- `x86_64-darwin` (Intel Mac): nixpkgs 26.05 is the LAST release supporting
  x86_64-darwin. Plan accordingly.
- 4 packages are Linux-only (gated with `lib.optionals stdenv.isLinux` in home.nix):
  `calicoctl`, `nerdctl`, `opencode`, `goofys`. Dropped automatically on macOS.

## Initial activation (per host)

```bash
# Linux (local + o.jjo.us.to)
nix run github:nix-community/home-manager -- switch --flake ~/nix-env#jjo@x86_64-linux

# macOS (Intel)
nix run github:nix-community/home-manager -- switch --flake ~/nix-env#jjo@x86_64-darwin
```

Pre-flight: remove any imperative `nix profile` entries that are now in `home.nix`
to avoid collisions:
```
nix profile list
nix profile remove <store-path-or-name>
```
