#!/usr/bin/env bash
set -uf -o pipefail
IFS=$'\n\t'

# Reference:
# https://github.com/cirala/vifmimg/blob/master/vifmrun

# pid="${PPID}"
FIFO_UEBERZUG="$(mktemp --dry-run --suffix "fzf-$$-ueberzug")"
# FIFO_UEBERZUG="fifo"
export FIFO_UEBERZUG

launch() {
  nvim "$@"
  # nvim -u NONE -c ":so plugin.vim" sample
  # nvim -c ":e sample"
}

cleanup() {
  rm "$FIFO_UEBERZUG" 2> /dev/null
  pkill -P $$ 2> /dev/null
}

pkill -P $$ 2> /dev/null
rm "$FIFO_UEBERZUG" 2> /dev/null
mkfifo "$FIFO_UEBERZUG"
trap cleanup EXIT 2> /dev/null
tail -f "$FIFO_UEBERZUG" | ueberzug layer --parser json &

launch "$@"
cleanup
