# git push-update
Push with "server-side" merge or rebase.

This script makes centralized workflow easier. No need to pull before push anymore, just push your commits and see them rebased or merged to target branch (if there are no conflicts). No change to local repository is made except updating remote branch reference. It runs in isolated environment - it either succeeds or aborts with no half-done work.

###Usage:

      git push-update [options] <remoteName> <remoteBranch> [<source>...]

`<remoteName>` is the name of registered remote repository where you want to push your changes to. <remoteBranch> is branch which you want to update with your commits.

**NOTE**: Be careful to not to push to wrong branch, if it succeeds without conflict then there is no additional check, the commits will go there. This is especially bad for **`merge`** type, because it may create incorrect ancestry relation which look ugly in revision graph and will affect later merges.

###Options:

**`--type=<type>`** - type of update.

Can be:

 - **`rebase`** `<source>` can be empty, single commit or a range. If `<source>` is empty it is treated as `HEAD`. For single commit everything unknown to remote is rebased. For range - only the specified range. There is an additional validation that rebased commits are equivalent to older, so you can repeat rebase without conflict. If the commit is changes during rebase (despite of all file changes were merged automaticallly) the update aborts and suggests to update manually.
 - **`merge`** `<source>` can be either empty, or name of local branch. If it's empty then the currently checked out branch is taken. If HEAD is detached or `<source>` is not a branch but expression which resolves to hash merge fails, because the branch name is needed for the merge message.

**NOTE**: mixing merges and rebases might make sense in some workflow, but you should know what are you doing.

**`--host=<type>`** - name of "remote" for merge message. Should indicate the current repository. For collaboration in a project with several people it can be your nickname for example. By default hostname is used.

##CVCS vs `push-update`

Some kind of cheatsheet which provides analogs for centralized VCS, svn here for example which should be most familiar for everybody.

|             |svn|`push-update` with merges|`push-update` with rebases|
|-------------|---|-------------------------|--------------------------|
|Start working|`svn checkout <url>`|`git clone <url>`| *same* |
|Make your changes|Edit files|Edit files, `git commit/revert/reset`| *same* |
|Update with progress|`svn update`|`git pull --merge`|`git pull --rebase`|
|Submit one or several files|`svn commit <file>...`|N/A|`git commit <file>... && git ` **`push-update`** `--type=rebase 'HEAD^!'` <sup>1</sup>|
|Submit all changes|`svn commit`|`git ` **`push-update`** ` --type=merge`|`git ` **`push-update`** ` --type=rebase`|

1) if you have changed and committed same file before already in this local branch and have not pushed it then that change will not be pushed, unlike svn. It can be what you want or what you don't want.
