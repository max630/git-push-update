# git push-update
Push with "server-side" merge or rebase.

This script makes centralized workflow easier. No need to pull before push anymore, just push your commits and see them rebased or merged to target branch (if there are no conflicts). No change to local repository is made except updating remote branch reference. It runs in isolated environment - it either succeeds or aborts with no half-done work. No changes to server code is needed.

###Usage:

      git push-update [options] <source>...

`<source>` are the commit which you wish to push, it depends on update type what is accepted there.

###Options:

**`--type=<type>`** - type of update.

Can be:

 - **`rebase`** `<source>` can be empty, single commit or a range. If `<source>` is empty it is treated as `HEAD`. For single commit everything unknown to remote is rebased. For range - only the specified range. There is an additional validation that rebased commits are equivalent to older, so you can repeat rebase without conflict. If the commit is changes during rebase (despite of all file changes were merged automaticallly) the update aborts and suggests to update manually.
 - **`merge`** `<source>` can be either empty, or name of local branch. If it's empty then the currently checked out branch is taken. If HEAD is detached or `<source>` is not a branch but expression which resolves to hash merge fails, because the branch name is needed for the merge message.

**NOTE**: mixing merges and rebases might make sense in some workflow, but you should know what are you doing.

**`--host=<type>`** - name of "remote" for merge message. Should indicate the current repository. For collaboration in a project with several people it can be your nickname for example. By default hostname is used.

**`--dest=<dest>`** - remote branch to push to, as remote reference (like `origin/master` or `refs/remotes/origin/master`). Must have tracking branch which contains the commits you are going to push. This prevents rebasing and merging to wrong remote branch, which would be very damaging because whole content of current branch would go there.

##CVCS vs `push-update`

Some kind of cheatsheet which provides analogs for centralized VCS, svn here for example which should be most familiar for everybody.

|             |svn|`push-update` with merges|`push-update` with rebases|
|-------------|---|-------------------------|--------------------------|
|Start working|`svn checkout <url>`|`git clone <url>`| *same* |
|Make your changes|Edit files|Edit files, `git commit/revert/reset`| *same* |
|Submit one or several files|`svn commit <file>...`|N/A|`git commit <file>... && git ` **`push-update`** `--type=rebase 'HEAD^!'` <sup>1</sup>|
|Submit all changes|`svn commit`|`git ` **`push-update`** ` --type=merge`|`git ` **`push-update`** ` --type=rebase`|
|Update with progress|`svn update`|`git pull --merge`|`git pull --rebase`|
|Discard your local changes|`svn revert`|`git fetch && git reset --hard origin/master` <sub>2</sup>| *same* |

1) if you have changed and committed same file before already in this local branch and have not pushed it then that change will not be pushed, unlike svn. It can be what you want or what you don't want.

2) This also updates with master progress. If it is undesirable you should reset to an older master commit.
