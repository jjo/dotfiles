#!/bin/bash
set -euo pipefail

home-manager expire-generations "-30 days"
nix-collect-garbage -d
