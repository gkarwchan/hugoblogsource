+++
title = "Are you still using `git checkout` for everything? It is time to switch to `gitswitch`"
date = 2024-09-21T10:41:54-06:00
short = true
toc = true
draft = false
tags = ["devops"]
categories = []
series = []
comment = true
+++

If you're like me and still rely on the trusty git checkout for a variety of tasks—like switching branches, restoring files, and checking out commits—then you're in for a treat. The Git community has made things easier by introducing two new commands to split the workload: git switch and git restore.

These new commands were created to reduce the overload on git checkout and make Git a bit more intuitive, especially for developers who sometimes found it confusing. Let's break it down!

## What git checkout used to do

The `git checkout` command was a Swiss Army knife in Git. It handled several different jobs, which could sometimes be confusing. With git checkout, you could:

1. Switching branches: 
```bash
git checkout <branch-name>
```

2. Create a new branch and switch to it:
```bash
git checkout -b <new-branch-name>
## or create a branch from a specific commit
git checkout -b <new-branch-name> <commit-hash>
```

3. Restoring files from the stage area
Files that were modified and added to staging area can be brought back to last 
```bash
git checkout <file>
```

4. Restoring files from specific commit
```bash
git checkout <commit-hash> --file
```

5. Checking out the code to a specific commit or tag:  
It is as well called `detached HEAD`, because the `HEAD` pointer will point to a specific commit instead of the latst commit in the current branch:
```bash
git checkout (<commit-hash> | <tag-name>)
```

## Why `checkout` was so overloaded
While all of these actions are useful, bundling them into one command could cause confusion, especially for newer users. You might ask, "Why does git checkout work in some situations and not others?" For instance, sometimes it works with staged files, sometimes with uncommitted changes, and other times it doesn't unless you commit first.

Because git checkout had to handle so many different tasks, the Git community decided to split its functionality. The command still works for backward compatibility, but now we have two specialized commands that simplify common tasks: git switch and git restore.
 
## How to simplify your Git workflow

With Git 2.23, two new commands were introduced to ease the confusion: git switch for handling branches and git restore for managing files. These commands break down checkout's responsibilities and make Git operations clearer.

#### git switch

`git switch` is a command for switching branches.  
So you have a command to switch to another branch

```bash
git switch <branch-name>
```
Or create a new branch from existing status
```bash
git switch -c <new-branch-name>
```


#### git restore
`git restore` is focusing on restoing files from specific commit, or disregard the changes in staging, or working area.

```bash
git restore <file>
## or restore all files
git restore .
```

Or you can restore to a specific commit 
```bash
git restore --source <commit-hash> <file> 
```

## Wrapping up
While `git checkout` still works, switching to the new commands can make you Git workflow more intutive and less confusion. Branches, files, and commits are all just pointers in your Git history, but by using these specialized commands, you’ll reduce the mental load and avoid mistakes.

Take a few minutes to familiarize yourself with these new commands—you’ll be glad you did!
