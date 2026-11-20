#!/usr/bin/env bash
# usage: rename-tokens.sh <map> <path>...   (run at the root of a git repo; rewrites TRACKED files only)
set -euo pipefail
map=$1; shift
# longest "old" first, so a long name is never clobbered by a shorter prefix of itself
awk 'NF==2 {print length($1), $1, $2}' "$map" | sort -rn | cut -d' ' -f2- |
while read -r old new; do
  git grep -lF -e "$old" -- "$@" 2>/dev/null | while read -r f; do
    OLD="$old" NEW="$new" perl -pi -e 'BEGIN{$o=quotemeta($ENV{OLD}); $n=$ENV{NEW}} s/(?<![\w-])$o(?![\w-])/$n/g' "$f"
  done
done
