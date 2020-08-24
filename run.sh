#!/bin/bash

# Скрипт прервется, если встретит непроинициализированную переменную
# либо какая-то функция/команда вернет код ответа, отличный от нуля
set -eu

########## Подготавливаем окружение ############################################

FILE="${1:-./poem.txt}"
OUT_DIR="${2:-./poetry}"
OUT_FILE="${OUT_DIR}/README.md"

export GIT_DIR="${OUT_DIR}/.git"
export GIT_WORK_TREE="$OUT_DIR"

if [[ -d "$OUT_DIR" ]]; then
    echo "Directory ${OUT_DIR} exists already" >&2
    exit 1
fi

if [[ ! -s "$FILE" ]]; then
    echo "File ${FILE} doesn't exist or empty" >&2
    exit 2
fi

mkdir -p "$OUT_DIR"
touch "$OUT_FILE"

git init 

# Убеждаемся, что гит не будет подписывать коммиты
git config --local commit.gpgsign no

########## Список будущих контрибьюторов #######################################

declare -A AUTHORS=( )
AUTHORS["Linus Torvalds"]=torvalds@linux-foundation.org
AUTHORS["Vitalik Buterin"]=v@buterin.com
AUTHORS["Bjarne Stroustrup"]=bjarne@stroustrup.com
AUTHORS["Brendan Gregg"]=brendan.d.gregg@gmail.com
AUTHORS["Guido van Rossum"]=guido@python.org
AUTHORS["Aleksey Boomburum"]=boomburum@gmail.com
AUTHORS["Ivan Vasilev"]=slavniyteo@gmail.com

# Массив имен разработчиков, чтобы идти по ним в цикле
# В функции get-next-author-name
declare -a AUTHOR_NAMES=( "${!AUTHORS[@]}" )

########## Функции #############################################################

get-next-author-name() {
    local GLOBAL_AUTHOR_INDEX="$1"
    local AUTHOR_INDEX="$(($GLOBAL_AUTHOR_INDEX % "${#AUTHOR_NAMES[@]}"))"

    echo "${AUTHOR_NAMES["$AUTHOR_INDEX"]}"
}

commit-one-line() {
    local AUTHOR="$1"
    local LINE="$2"
    local AUTHOR_EMAIL="${AUTHORS["$AUTHOR"]}"

    # Вставляем строку в начало файла
    echo "$LINE" | cat - "$OUT_FILE" > temp
    mv temp "$OUT_FILE"

    git add -A

    git config --local user.name "$AUTHOR"
    git config --local user.email "$AUTHOR_EMAIL"

    # Добавляем '| ' в начало, 
    # чтобы избежать проблем с пустым сообщением коммита
    git commit -m "| $LINE"

    # Избавляемся от сайд-эффектов функции
    git config --local --unset user.name
    git config --local --unset user.email
}

########## Основной цикл #######################################################

LINE_IDX=0
while IFS= read LINE; do
    LINE_IDX="$((LINE_IDX + 1))"
    AUTHOR="$(get-next-author-name "$LINE_IDX")"

    commit-one-line "$AUTHOR" "$LINE"
done <<<"$(tac "$FILE")" # Читаем файл от последней строки к первой

################################################################################
