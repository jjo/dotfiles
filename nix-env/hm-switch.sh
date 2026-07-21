#!/bin/bash
set -euo pipefail

case "$(uname -s)" in
  Darwin) key=jjo@mac ;;
  *)      key=jjo@linux ;;
esac

flake="${FLAKE:-$HOME/nix-env}"

home-manager switch --flake "$flake#$key"
