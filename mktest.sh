#!/bin/sh

set -e

SRCDIR=$(pwd)

DIR=$(mktemp -d)
mkdir "$DIR/origin"

export GIT_EDITOR=true

(
    cd "$DIR/origin"
    git init
    git commit --allow-empty -m init
    touch simplefile
    touch "space file"
    touch "trailing space file "
    touch " leading space file"
    touch "quote\"file"
    touch "sinlequote'file"
    touch "newline
file"
    git add .
    git commit -m 'files added'
    git clone . clone
    # smoke
    git commit --allow-empty -m 'advance'
    git checkout --detach master
    (
        cd clone
        echo line1 >>simplefile
        echo line1 >>"space file"
        echo line1 >>"trailing space file "
        echo line1 >>" leading space file"
        echo line1 >>"quote\"file"
        echo line1 >>"sinlequote'file"
        echo line1 >>"newline
file"
        git commit -m edits -a
        "$SRCDIR/git-push-merge" origin master
        git pull origin master
    )
    git checkout master
    git commit --allow-empty -m 'advance'
    git checkout --detach master
    (
        cd clone
        echo line1 >newfile
        git add newfile
        git commit -m 'newfile'
        "$SRCDIR/git-push-merge" origin master
        git pull origin master
    )
    git checkout master
    git commit --allow-empty -m advance
    git checkout --detach master
    (
        cd clone
        git rm newfile
        git commit -m 'rm newfile'
        "$SRCDIR/git-push-merge" origin master
        git pull origin master
    )
)

rm -rf "$DIR/origin"
rmdir "$DIR"
