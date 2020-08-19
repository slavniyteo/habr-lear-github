#!/bin/bash

set -eu

################################################################################

export GIT_DIR="./poetry/.git"
export GIT_WORK_TREE="./poetry"
FILE="${1:-./poem.txt}"
OUT_FILE="./poetry/README.md"

################################################################################

declare -A AUTHORS=( )
AUTHORS["Linus Torvalds"]=torvalds@linux-foundation.org
AUTHORS["Vitalik Buterin"]=v@buterin.com
AUTHORS["Bjarne Stroustrup"]=bjarne@stroustrup.com
AUTHORS["Brendan Gregg"]=brendan.d.gregg@gmail.com
AUTHORS["Guido van Rossum"]=guido@python.org
AUTHORS["Ivan Vasilev"]=slavniyteo@gmail.com

declare -a AUTHOR_NAMES=( "${!AUTHORS[@]}" )

get-next-author-name() {
  GLOBAL_AUTHOR_INDEX="$1"
  AUTHOR_INDEX="$(($GLOBAL_AUTHOR_INDEX % "${#AUTHOR_NAMES[@]}"))"
  echo "${AUTHOR_NAMES["$AUTHOR_INDEX"]}"
}

commit () {
  local AUTHOR="$1"
  local LINE="$2"
  local AUTHOR_EMAIL="${AUTHORS["$AUTHOR"]}"

  echo "$LINE" | cat - "$OUT_FILE" > temp
  mv temp "$OUT_FILE"

  git add -A

  git config --local user.name "$AUTHOR"
  git config --local user.email "$AUTHOR_EMAIL"
  git commit -m "| $LINE"
  git config --local --unset user.name
  git config --local --unset user.email
}

################################################################################

GLOBAL_AUTHOR_INDEX=0
while IFS= read LINE; do
  GLOBAL_AUTHOR_INDEX="$((GLOBAL_AUTHOR_INDEX + 1))"
  AUTHOR="$(get-next-author-name "$GLOBAL_AUTHOR_INDEX")"
  commit "$AUTHOR" "$LINE"
done <<<"$(tac "$FILE")"

################################################################################
