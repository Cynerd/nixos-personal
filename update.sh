#!/bin/sh
set -eu

nix flake update
git add flake.lock
git commit -m 'Flake inputs update'
