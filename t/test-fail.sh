#!/bin/sh

set -e

SELF_PATH=$(realpath "$0")
TDIR=$(dirname "$SELF_PATH")
. "$TDIR/test-lib.sh"

DIR=$(mktemp -d)
mkdir "$DIR/origin"
echo "Test directory: $DIR"

(
    cd "$DIR/origin"
    git init -q
    git commit -q --allow-empty -m init
    touch simplefile
    git add .
    git commit -q -m 'files added'
    git clone -q . clone
    git commit -q --allow-empty -m advance1
    (
        sleep 1
        git commit -q --allow-empty -m advance2
        git checkout -q --detach master
    ) &
    (
        cd clone
        echo line1 >>simplefile
        git commit -q -m edits -a
        GIT_EDITOR="$SRCDIR/t/testeditor.sh"
        export GIT_EDITOR
        export GIT_EDITOR_CASE=wait
        "$SRCDIR/git-push-update" HEAD || true
        git log --oneline --decorate --graph --all | cat
    )
    test "$?" -eq 0
)
test "$?" -eq 0

rm -rf "$DIR/origin"
rmdir "$DIR"
