+++
title = "Git tools every DevOps should know"
date = 2024-09-20T18:41:54-06:00
short = true
toc = true
draft = false
tags = ["devops"]
categories = []
series = []
comment = true
+++

As a DevOps who maintain an active Git repo, where hundreds of commits are running everyday, you will need to deal with issues from time to time, and those issues require some good knowledge of git, and some of its tools that will help you in your job.  
We are going to cover some common issues that the team face while dealing with git, and what tools are used to deal with them.  
We we cover these issues:  

* delete permenantly files from the whole history.
* maintain the health of the repository by cleaning its **garbage** from time to time.
* speed up working with huge repository.
* spped up dealing with huge files.
* generate log when it is time for creating a release.


# Cleaning dead, and unreachable items in your repo.

Similar to how you do `Disk Cleanup` on your computer from time to time to clean dead files that being collected over time, Git repository collect some unreachable items (commits, branches...).  
The command **`git gc`** which is (Git garbage collection), will do that process.  
The command will do the following:  

1. Compress objects
2. Clean up orphan data (like unreachable commits, or branches)
3. Enhance performance

> Remarkable to know that some commands will do built-in auto `gc`
> the following commands do that:  
> 1. git commit
> 2. git merge
> 3. git pull
> 4. git rebase

Although the above commands do built-in cleaning, but it is important from time to time you run it on the repository.  
Some DevOps run the command though CI/CD after every release.  

# Dealing with large files:
When adding a file to git, git will add it to its database, and keep lots of metadata and track information on it.
If the file is huge (gigabytes), then tracking that file in git database will be a costly process.
That is why git will limit the file size uploaded.

GitHub for example has the following limits depend on your GitHub plan:


| Product | Maximum file size |
| -- | -- |
| GitHub Free |	2 GB |
| GitHub Pro | 2 GB |
| GitHub Team	| 4 GB |
| GitHub Enterprise Cloud	| 5 GB| 

To keep maintaining those large files, there is an extension tool called [Git Large File Storage](https://git-lfs.com/).
The tool doesn’t load the file into Git database, but it load it into a separate place, and keep a pointer to the file in the database, and track the pointer instead of the file.  

### How to use it?
The link above has a downloadable installer for Git LFS. It is a git CLI extension. After you install the above installer, you run the following:  

```bash
git lfs install
```

Then you can configure specific extensions to be tracked by LFS.

```bash
git lfs track "*.pdf"
```
So any PDF file will be tracked by LFS.  

# Delete files permenantley from Git history

Someone pushed a file that has secrets, or very large file that was not necessary in our code.  
We need to delete it, but we need to delete it permenantly from all git history.  

If the file was commited to local repository but was not pushed yet to the remote git provider.  

Then you need to use one of the tools:  

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

