#!/bin/sh

set -e

SELF_PATH=$(realpath "$0")
TDIR=$(dirname "$SELF_PATH")
. "$TDIR/test-lib.sh"

DIR=$(mktemp -d)
mkdir "$DIR/origin"
echo "Test directory: $DIR"

export TYPE="$1"
export GIT_EDITOR=true

(
    cd "$DIR/origin"
    git init -q
    git commit -q --allow-empty -m init
    touch simplefile
    touch "space file"
    #touch "trailing space file "
    touch " leading space file"
    #touch "quote\"file"
    touch "sinlequote'file"
    #touch "newline
#file"
    seq 1 9 >2edit
    git add .
    git commit -q -m 'files added'
    git clone -q . clone
    # smoke
    git commit -q --allow-empty -m 'advance'
    git checkout -q --detach master
    (
        cd clone
        echo line1 >>simplefile
        echo line1 >>"space file"
        #echo line1 >>"trailing space file "
        echo line1 >>" leading space file"
        #echo line1 >>"quote\"file"
        echo line1 >>"sinlequote'file"
        #echo line1 >>"newline
#file"
        git commit -q -m edits -a
        "$SRCDIR/git-push-update" --type="$TYPE" HEAD
        git reset --hard origin/master
    )
    test "$?" -eq 0
    git checkout -q master
    git commit -q --allow-empty -m 'advance'
    git checkout -q --detach master
    (
        cd clone
        echo line1 >newfile
        git add newfile
        git commit -q -m 'newfile'
        "$SRCDIR/git-push-update" --type="$TYPE" HEAD
        git reset --hard origin/master
    )
    test "$?" -eq 0
    git checkout -q master
    git commit -q --allow-empty -m advance
    git checkout -q --detach master
    (
        cd clone
        git rm -q newfile
        git commit -q -m 'rm newfile'
        "$SRCDIR/git-push-update" --type="$TYPE" HEAD
        git reset --hard origin/master
    )
    test "$?" -eq 0
    git checkout -q master
    sed -i 2edit -e s/3/3edited/
    git add 2edit
    git commit -q -m "edit line3"
    git checkout -q --detach master
    (
        cd clone
        sed -i 2edit -e s/7/7edited/
        git add 2edit
        git commit -q -m "edit line7"
        git revert --no-edit HEAD
        "$SRCDIR/git-push-update" --type="$TYPE" HEAD
        git reset --hard origin/master
    )
    test "$?" -eq 0
    git checkout -q -B branch1 master
    git commit -q --allow-empty -m advance
    git checkout -q --detach branch1
    (
        cd clone
        git commit -q --allow-empty -m 'nothing'
        ! "$SRCDIR/git-push-update" --type="$TYPE" --dest=origin/branch1 HEAD
        # git checkout -q -B branch1 master
        # git branch -q -u origin/branch1
        # "$SRCDIR/git-push-update" --type="$TYPE" --dest=origin/branch1 HEAD
        git log --oneline --decorate --graph --all | cat
    )
    test "$?" -eq 0
)
test "$?" -eq 0

rm -rf "$DIR/origin"
rmdir "$DIR"
