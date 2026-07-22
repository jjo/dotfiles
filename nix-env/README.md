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

## 0) Initial setup (one-time per host)

### Step 0a — remove imperative nix profile entries that conflict

Check what's in your profile:

```
nix profile list
nix profile remove <store-path-or-name>
```

Historically conflict-prone: `nix-env`, `openstackclient`, `rancher`, `rtk` (now
inside `home.nix`), and any stale `home-manager-path` entries.

### Step 0b — bootstrap home-manager with a one-shot `nix run`

```
cd ~/nix-env
git add -f home.nix                    # ensure flake sees it
nix run github:nix-community/home-manager -- switch --flake .#jjo@linux
```

On the Mac: `.#jjo@mac`.

This is the **only** manual `nix run` you'll ever need — the `switch` installs
`programs.home-manager.enable = true` onto your PATH, so every future switch is
just:

```
cd ~/nix-env && git add home.nix && home-manager switch --flake .#jjo@linux
```

After switch, confirm it worked:

```
hash -r                                # or exec -l $SHELL
home-manager --version                 # should print version
for b in delta argo yt-dlp openstack; do command -v $b && echo OK $b; done
```

### Step 0c — (macOS only) ensure home-manager CLI lands on PATH

macOS doesn't use `programs.home-manager.enable` the same way. If `home-manager`
doesn't appear after the first switch, re-run once with `nix run` — it'll stick
after the second switch.

### Step 0d — commit and push (lock in the flake)

```
git add flake.nix home.nix README.md flake.lock hm-switch.sh hm-update.sh hm-gc.sh
git commit -m "nix-env: home-manager migration (jjo)"
git push
```

Then `git pull && home-manager switch` on o.jjo.us.to and the Mac.

## 1) Add / remove a package

All edits happen in `home.nix`'s `home.packages = [ ... ]` list.

Add: insert `pkgname` (respect existing grouping).
Remove: delete the line.

```
cd ~/nix-env
git add home.nix                                  # flake reads only git-tracked files
home-manager switch --flake .#jjo@linux    # builds + activates; idempotent
```

On the Mac: `--flake .#jjo@mac`.

`switch` rebuilds and atomically swaps the generation. If a build fails, the
current generation is untouched — nothing breaks.

Roll back a bad switch:

```
home-manager generations                          # list generations w/ timestamps
home-manager switch --switch-generation <N>       # rollback by number
```

## 2) Upgrade all packages

Packages come from `nixpkgs` and `home-manager` flake inputs pinned in
`flake.lock`. Upgrading = bumping the lock, then switching.

```
cd ~/nix-env
nix flake update                                  # re-pins nixpkgs AND home-manager
home-manager switch --flake .#jjo@linux
```

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
nix eval .#homeConfigurations."jjo@linux".config.home.packages \
  --apply 'p: map (x: {n=x.name; v=x.version;}) p' | jq
nix flake metadata github:nixos/nixpkgs/$(jq -r .nodes.nixpkgs.locked.rev flake.lock)
```

### d) Shell into an ad-hoc environment WITHOUT installing

```
nix shell nixpkgs#<pkg1> nixpkgs#<pkg2>            # temporary, no profile mutation
nix run nixpkgs#<pkg>                              # run once, no install
```

### e) Edit a package's nix expression locally (overlay pattern)

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
The overlay file lives in `overlays/nixpkgs.nix` — add it to `modules` in
`flake.nix`'s `mkHM` call, e.g.:

```nix
mkHM = pkgs': home-manager.lib.homeManagerConfiguration {
  pkgs = pkgs';
  modules = [ ./home.nix ./overlays/nixpkgs.nix ];
};
```

### f) Two-machine sync (local + o.jjo.us.to + Mac)

Same repo on all boxes. Edit locally → commit → push. On each remote:

```
cd ~/nix-env && git pull && home-manager switch --flake .#jjo@linux
```

Host-specific packages via a `hosts/<hostname>.nix` module:

```nix
# flake.nix inside mkHM
modules = [ ./home.nix ./hosts/<host>.nix ];
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
home-manager switch --flake .#jjo@linux --verbose 2>&1 | grep -E 'removed|added|changed'
```

List of removed/added/changed packages prints; verify nothing unexpected was dropped.

### j) Preview before switching

```
home-manager build --flake .#jjo@linux
nvd diff ~/.local/state/nix/profiles/home-manager ./result
# then if happy:
home-manager switch --flake .#jjo@linux
```

(`nvd` is a tool: `nix profile install nixpkgs#nvd` once.)

### k) Periodic health check

```
nix flake check                                   # validate the flake without building
nix flake show                                    # see all outputs
```

## Reference: files in this repo

| File | Purpose |
|------|---------|
| `flake.nix` | Inputs (nixpkgs, nixpkgs-darwin, home-manager), `mkHM` helper, `homeConfigurations."jjo@<host>"` outputs |
| `flake.lock` | Pinned revisions for all inputs (commit alongside config changes) |
| `home.nix` | Shared module: `home.packages` + `maybe`/`linuxOnly` gates |
| `hm-switch.sh` | `home-manager switch --flake .#jjo@{linux,mac}` (auto-detects platform) |
| `hm-update.sh` | `nix flake update` + `hm-switch.sh` |
| `hm-gc.sh` | `home-manager expire-generations "-30 days"` + `nix-collect-garbage -d` |
| `overlays/` | (optional) local package overrides |
| `hosts/` | (optional) per-host specific modules |

## Platform notes

- **x86_64-darwin** (Intel Mac): nixpkgs 26.05 is the LAST release supporting
  x86_64-darwin. Plan accordingly.
- **Linux-only** (gated with `linuxOnly` in home.nix): `calicoctl`, `nerdctl`,
  `opencode`, `goofys`. Dropped automatically on macOS.
- **26.05-darwin only** (gated with the `maybe` helper): `herdr`,
  `silver-searcher-ng`. Not present in nixpkgs-26.05-darwin; drop automatically
  when building on the Mac.

## Initial activation (per host)

```bash
# Linux (local + o.jjo.us.to)
nix run github:nix-community/home-manager -- switch --flake ~/nix-env#jjo@linux

# macOS (Intel)
nix run github:nix-community/home-manager -- switch --flake ~/nix-env#jjo@mac
```

Pre-flight: remove any imperative `nix profile` entries that are now in `home.nix`
to avoid collisions:

```
nix profile list
nix profile remove <store-path-or-name>
```
