#!/usr/bin/env bash
set -eo pipefail
IFS=$'\n\t'

if [[ -z "${NVIM_LISTEN_ADDRESS}" ]]; then
    "C:/tools/neovim/Neovim/bin/nvim.exe" "$*"
  else
    "C:/Python36/Scripts/nvr.exe" -cc split "$*" --remote-wait-silent
fi
