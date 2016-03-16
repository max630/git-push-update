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
    seq 1 100 >file
    git add file
    git commit -q -m 'file'
    git checkout -q -b b1 HEAD
    sed -i file -e 's/^1$/1edited/'
    git commit -q -m 'line 1' file
    git checkout -q master
    git clone -q . clone
    sed -i file -e 's/^2$/2edited/'
    git commit -q -m 'line 2' file
    git checkout -q -B b1 HEAD
    sed -i file -e 's/^1$/1edited/'
    git commit -q -m 'line 1' file
    git checkout -q --detach b1
    (
        cd clone
        git checkout -q -b b1 origin/b1
        sed -i file -e 's/^10$/10edited/'
        git commit -q -m 'line 10' file
        must_fail "$SRCDIR/git-push-update" --type=rebase --no-fork-point HEAD
        "$SRCDIR/git-push-update" --type=rebase HEAD
        git log --oneline --decorate --graph --all | cat
    )
)

rm -rf "$DIR/origin"
rmdir "$DIR"
