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
    seq 1 10 >file
    git add file
    git commit -q --allow-empty -m init
    git clone -q . clone
    sed -i file -e s/5/5edit/
    git commit -q -a -m 'edit line 5'
    git checkout -q --detach master
    (
        cd clone
        sed -i file -e s/7/7edit/
        git commit -q -a -m 'edit line 7'
        "$SRCDIR/git-push-merge" --type=rebase origin master
        git log --oneline --decorate --graph --all | cat
    )
)

rm -rf "$DIR/origin"
rmdir "$DIR"
