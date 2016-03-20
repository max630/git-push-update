# git push-update
Push with "server-side" merge or rebase.

This script facilitates trunk-based workflow as it used to be in centralized VCS-es. No need to pull before push anymore, just push your commits and see them rebased or merged to target branch (if there are no conflicts). Your current branch and working copy files will not change, so it can be done without interruption of other work.

- [Installation](#installation)
- [Usage](#usage)
  - [Options](#options)
- [CVCS vs `push-update`](#cvcs-vs-push-update)
- [How it Works](#how-it-works)
- [Credits](#credits)

##Installation

Get script [here](https://github.com/max630/git-push-update/raw/master/git-push-update). It is a shell script which requires only git itself and basic shell commands. No changes to server is needed.

##Usage:

      git-push-update [options] <source>...

`<source>` are the commit which you wish to push, it depends on update type what is accepted there.

###Options:

**`--type=<type>`** - type of update.

Can be:

 - **`rebase`** `<source>` can be a single commit or range. For single commit "rebase with forkpoint" is performed, so that if upstream branch was rebeased it is handled nicely. For range - only the specified range is rebased. There is an additional validation that rebased commits are equivalent to older, so you can repeat rebase without conflict. If the commit is changes during rebase (despite of all file changes were merged automaticallly) the update aborts and suggests to update manually.
 - **`merge`** `<source>` can be either HEAD, or name of local branch. If it's empty then the currently checked out branch is taken. If specified HEAD is detached or `<source>` is not a branch but expression which resolves to hash merge fails, because the branch name is needed for the merge message.

**NOTE**: mixing merges and rebases might make sense in some workflow, but you should know what are you doing.

**`--host=<type>`** - name of "remote" for merge message. Should indicate the current repository. For collaboration in a project with several people it can be your nickname for example. By default hostname is used.

**`--dest=<dest>`** - remote branch to push to, as remote reference (like `origin/master` or `refs/remotes/origin/master`). By default the branch tracked by currently checked out branch is used. The target remote branch must have tracking branch which contains the commits you are going to push. This prevents rebasing and merging to wrong remote branch, which would be very damaging because whole content of current branch would go there.

**`--no-fork-point`** - for *`rebase`* disable search of forkpoint, just run regular rebase.

##CVCS vs `push-update`

Some kind of cheatsheet which provides analogs for centralized VCS, svn here for example.

|             |svn|`push-update` with merges|`push-update` with rebases|
|-------------|---|-------------------------|--------------------------|
|Start working|`svn checkout <url>`|`git clone <url>`| *same* |
|Make your changes|Edit files|Edit files, `git commit/revert/reset`| *same* |
|Update with progress|`svn update`|`git pull --merge`|`git pull --rebase`|
|View local changed|`svn diff`|`git diff HEAD@{u}...`| *same* <sup>1</sup> |
|Submit one or several files|`svn commit <file>...`|N/A|`git commit <file>... && git ` **`push-update`** `--type=rebase 'HEAD^!'` <sup>2</sup>|
|Submit all changes|`svn commit`|`git ` **`push-update`** ` --type=merge`|`git ` **`push-update`** ` --type=rebase`|
|Discard your local changes|`svn revert`|`git fetch && git reset --hard origin/master` <sup>3</sup>| *same* |

1) If some commts have already pushed to upstream, this will show their changes also.

2) if you have changed and committed same file before already in this local branch and have not pushed it then that change will not be pushed, unlike svn. It can be what you want or what you don't want.

3) This also updates with master progress. If it is undesirable you should reset to an older master commit.

##How it works

The rebase or merge is actually done locally, but in temporary clone. With help of shared objects and sparse checkout it does not consume much space - it takes only as much you have actually changed.

##Credits

Inspired by

- [this](http://thread.gmane.org/gmane.comp.version-control.git/247237) thread in git mailing list.
- `pushrebase` [extension](https://bitbucket.org/facebook/hg-experimental) to mercurial
