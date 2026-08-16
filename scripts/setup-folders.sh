#!/usr/bin/env bash
set -euo pipefail

echo "==> Creating clean developer & personal workspace taxonomy..."

mkdir -p "$HOME/Developer/projects"
mkdir -p "$HOME/Developer/uni"
mkdir -p "$HOME/Developer/games"
mkdir -p "$HOME/Developer/repos"
mkdir -p "$HOME/Developer/scratch"

mkdir -p "$HOME/Documents/uni"
mkdir -p "$HOME/Documents/personal"

mkdir -p "$HOME/Movies"

echo "    Directory structure created successfully."
