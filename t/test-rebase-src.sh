#!/bin/sh

set -e

SELF_PATH=$(realpath "$0")
TDIR=$(dirname "$SELF_PATH")
. "$TDIR/test-lib.sh"

DIR=$(mktemp -d)
mkdir "$DIR/origin"
echo "Test directory: $DIR"

commit()
{
    sed -i file -e "s/"'^'"$1"'$'"/$1e/"
    git commit -q -m "e $1" file
}

(
    cd "$DIR/origin"
    git init -q
    seq 1 100 >file
    git add file
    git commit -q -m init
    git clone -q . clone
    git commit -q --allow-empty -m 'advance'
    git checkout -q --detach master
    (
        cd clone
        commit 1
        commit 5
        commit 10
        commit 15
        commit 20
        commit 25
        commit 30
        commit 35
        commit 40
        commit 45
        commit 50
        commit 55
        commit 60
        commit 65
        "$SRCDIR/git-push-update" --type=rebase HEAD'^!'
        "$SRCDIR/git-push-update" --type=rebase ^HEAD~5 HEAD~3
        "$SRCDIR/git-push-update" --type=rebase HEAD~7
        git log --oneline --decorate --graph --all | cat
    )
    test "$?" -eq 0
)
test "$?" -eq 0

rm -rf "$DIR/origin"
rmdir "$DIR"
