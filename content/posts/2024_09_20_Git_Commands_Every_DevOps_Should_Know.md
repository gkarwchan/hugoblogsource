+++
title = "Git commands every DevOps should know"
date = 2024-09-20T18:41:54-06:00
short = true
toc = true
draft = false
tags = ["devops"]
categories = []
series = []
comment = true
+++


# Purge a file permenantly from the whole history of the repository

So, someone pushed a file that has secrets, or very large file that was not necessary in our code.  
We need to delete it, but we need to delete it permenantly from all git history.  

If the file was commited to local repository but was not pushed yet to the remote git provider.  

```bash
git rm <file-path>
# in case you need to make a copy from the file before then
# the above command will delete it from the stage but not from the disk
git rm --cached <file-path>

# then you do amend, because amend will rewrite the last commit
git commit --amend

# the previous command will invoke the editor to allow you to edit the commited message.
# if you don't care to change the commited message and want to reuse it
# then pass the C (upper C) argument 
git commit --amend -CHEAD

# the previous command will clear the file from the history of the local repo
git push
```
But what if you already pushed the file to the remote repository? Then you need to use one of the tools:  

* git filter-repo
* BFG Repo-Cleaner

These tools will re-write the repository history, so you need first to close every open PR, because they might be effected, and might not work after the history was changed.


## Using BFG

BFG Repo-Cleaner is a tool that is an alternative to `git filter-repo`, but faster.  
BFG doesn't have the full features of `git filter-repo`, and its scope is way smaller.
It does only two things, but it do them well and faster than `git filter-repo`.

* delete files (either large or sensitive).
* replace text in files

This process alter the repo's history, which means will change the SHAs for that commit you are altering, and will change all its child and dependent commits.  
So before doing that, make sure to close any pull requestes in your repository.

BFG and other tools that will change the history will work on bare repository


```bash
# create bare repository
git clone --mirror git://github.com/<username>/myrepo.git

# delete the required file
java -jar bfg.jar --delete-files <path to files>

# or replace text in a file, which will arease all data
java -jar bfg.jar --replace-text <path to files>

# then you need to push with force
git push --force

git reflog expire --expire=now --all
$ git gc --prune=now

```

## Using git filter-repo

git-filter-repo doesn't need to work or bare repo, and can work on the normal (work tree) repo.  

```bash
git filter-repo --invert-paths --path <path to files>

# then push with force
git push origin --force -all
```

