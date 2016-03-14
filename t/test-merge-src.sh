#!/bin/sh

set -e

SELF_PATH=$(realpath "$0")
TDIR=$(dirname "$SELF_PATH")
. "$TDIR/test-lib.sh"

DIR=$(mktemp -d)
mkdir "$DIR/origin"
echo "Test directory: $DIR"

export GIT_EDITOR=true

(
    cd "$DIR/origin"
    git init -q
    seq 1 10 >file
    git add file
    git commit -q -m init
    git clone -q . clone
    git commit -q --allow-empty -m 'advance'
    git checkout -q --detach master
    (
        cd clone
        git commit -q --allow-empty -m 'to merge as HEAD'
        "$SRCDIR/git-push-update" --type=merge origin master HEAD
        git merge -q origin/master
    )
    git checkout -q master
    git commit -q --allow-empty -m 'advance'
    git checkout -q --detach master
    (
        cd clone
        git commit -q --allow-empty -m 'to merge by older name'
        git branch -f b1
        git commit -q --allow-empty -m 'to discard'
        "$SRCDIR/git-push-update" --type=merge origin master b1
        git reset -q --hard origin/master
    )
    git checkout -q master
    git commit -q --allow-empty -m 'advance'
    git checkout -q --detach master
    (
        cd clone
        git commit -q --allow-empty -m 'to not merge by ref'
        git commit -q --allow-empty -m 'to discard'
        ! "$SRCDIR/git-push-update" --type=merge origin master HEAD~1
        git log --oneline --decorate --graph --all | cat
        git reset -q --hard origin/master
    )
)

rm -rf "$DIR/origin"
rmdir "$DIR"
