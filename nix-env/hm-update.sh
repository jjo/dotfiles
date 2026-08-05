#!/bin/bash
set -euo pipefail

case "$(uname -s)" in
  Darwin) key=jjo@mac ;;
  *)      key=jjo@linux ;;
esac

flake="${FLAKE:-$HOME/nix-env}"

# Determinate Nix multi-user installs don't set NIX_REMOTE in nix-daemon.sh →
# nix commands silently bypass the daemon and try to write /nix/store/*.lock as
# the client uid (no group access to /nix/store, which is root:nixbld 1775) →
# EACCES. Only set it when a daemon socket is present (multi-user install);
# single-user installs (e.g. o.jjo.us.to: /nix/store = jjo:jjo 755, no daemon)
# must stay unset or nix commands fail to connect.
if [ -z "${NIX_REMOTE:-}" ] && [ -S /nix/var/nix/daemon-socket/socket ]; then
  export NIX_REMOTE=daemon
fi

nix flake update --flake "$flake"
home-manager switch --flake "$flake#$key"
