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
        "$SRCDIR/git-push-update" --type=rebase HEAD
        git log --oneline --decorate --graph --all | cat
    )
    test "$?" -eq 0
)
test "$?" -eq 0

rm -rf "$DIR/origin"
rmdir "$DIR"
