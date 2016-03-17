#!/bin/sh

set -e

SELF_PATH=$(realpath "$0")
TDIR=$(dirname "$SELF_PATH")
. "$TDIR/test-lib.sh"

DIR=$(mktemp -d)
mkdir "$DIR/origin"
echo "Test directory: $DIR"

export TYPE=rebase
export GIT_EDITOR=true

(
    cd "$DIR/origin"
    git init -q
    seq 1 100 >file
    git add .
    git commit -q -m init
    git clone -q . clone
    git checkout -q --detach master
    (
        cd clone
        sed -i file -e 's/^1$/1e/'
        git commit -q -m 'edit 1' file
        sed -i file -e 's/^10$/10e/'
        git commit -q -m 'edit 10' file
        "$SRCDIR/git-push-update" --type=merge HEAD
        diff=$(git rev-list master...origin/master)
        test -z "$diff" || {
            echo master diverged from origin/master
            git log --oneline --graph --decorate --boundary master...origin/master | cat
            exit 1
        }
    )
    test "$?" -eq 0
    (
        cd clone
        sed -i file -e 's/^21$/21e/'
        git commit -q -m 'edit 21' file
        sed -i file -e 's/^30$/30e/'
        git commit -q -m 'edit 30' file
        "$SRCDIR/git-push-update" --type=rebase HEAD
        diff=$(git rev-list master...origin/master)
        test -z "$diff" || {
            echo master diverged from origin/master
            git log --oneline --graph --decorate --boundary master...origin/master | cat
            exit 1
        }
    )
    test "$?" -eq 0
    git checkout -q master
    git commit -q --allow-empty -m advance
    git checkout -q --detach master
    (
        cd clone
        sed -i file -e 's/^41$/41e/'
        git commit -q -m 'edit 41' file
        sed -i file -e 's/^50$/50e/'
        git commit -q -m 'edit 50' file
        git fetch -q origin
        git merge -q origin/master
        "$SRCDIR/git-push-update" --type=merge HEAD
        diff=$(git rev-list master...origin/master)
        test -n "$diff" || {
            echo master ff updated but it must not
            git log --oneline --graph --decorate --boundary master...origin/master | cat
            exit 1
        }
    )
    test "$?" -eq 0
    git checkout -q master
    git commit -q --allow-empty -m advance
    git checkout -q --detach master
    (
        cd clone
        sed -i file -e 's/^61$/61e/'
        git commit -q -m 'edit 61' file
        sed -i file -e 's/^70$/70e/'
        git commit -q -m 'edit 70' file
        "$SRCDIR/git-push-update" --type=rebase HEAD
        diff=$(git rev-list master...origin/master)
        test -n "$diff" || {
            echo master ff updated but it must not
            git log --oneline --graph --decorate --boundary master...origin/master | cat
            exit 1
        }
        git log --oneline --graph --decorate --all | cat
    )
    test "$?" -eq 0
)
test "$?" -eq 0
