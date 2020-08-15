#!/bin/bash

set -eu

################################################################################

cd poetry
FILE="${1:-../poem.txt}"

################################################################################

declare -a AUTHORS=( "Linus Torvalds" "Vitalik Buterin" "Ivan Vasilev" "Github" )
declare -A AUTHOR_EMAILS=( )
AUTHOR_EMAILS["Linus Torvalds"]=torvalds@linux-foundation.org
AUTHOR_EMAILS["Vitalik Buterin"]=v@buterin.com
AUTHOR_EMAILS["Ivan Vasilev"]=slavniyteo@gmail.com
AUTHOR_EMAILS[Github]=noreply@github.com

get-next-author-name() {
  GLOBAL_AUTHOR_INDEX="$1"
  AUTHOR_INDEX="$(($GLOBAL_AUTHOR_INDEX % "${#AUTHORS[@]}"))"
  echo "${AUTHORS["$AUTHOR_INDEX"]}"
}

commit () {
  local AUTHOR="$1"
  local LINE="$2"

  local AUTHOR_EMAIL="${AUTHOR_EMAILS["$AUTHOR"]}"

  git config --local user.name "$AUTHOR"
  git config --local user.email "$AUTHOR_EMAIL"
  echo "$LINE" >> result.txt
  git add -A
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
