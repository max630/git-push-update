#!/bin/sh

set -e

SRCDIR=$(pwd)
export SRCDIR

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
    (
        sleep 1
        git commit -q --allow-empty -m advance
        git checkout -q --detach master
    ) &
    (
        cd clone
        echo line1 >>simplefile
        git commit -q -m edits -a
        GIT_EDITOR="$SRCDIR/testeditor.sh"
        export GIT_EDITOR
        export GIT_EDITOR_CASE=wait
        "$SRCDIR/git-push-merge" origin master || true
        git pull -q origin master
    )
    git log --oneline --decorate --graph --all | cat
)

rm -rf "$DIR/origin"
rmdir "$DIR"
