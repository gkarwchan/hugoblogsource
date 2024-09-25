+++
title = "Git Tools Every DevOps Engineer Should Know"
date = 2024-09-25T18:41:54-06:00
short = true
toc = true
draft = false
tags = ["devops"]
categories = []
series = []
comment = true
+++

As a DevOps engineer managing an active Git repository with hundreds of commits daily, you'll inevitably face challenges that require a solid understanding of Git and its ecosystem. This post covers common issues that teams encounter while using Git and the tools used to address them. Each tool mentioned deserves a dedicated post, but here’s a brief overview of the essentials.

The tools we'll cover:
* Maintaining the health of the repository.
* Managing large files.
* Permanently deleting files from the entire history.
* Purging large historical data.
* Speeding up work on huge repositories.
* Automatically generating a changelog for releases.


# Cleaning Dead and Unreachable Items in Your Repo:

Just like performing a "Disk Cleanup" on your computer, a Git repository can accumulate unreachable items (such as old commits or branches). Git's git gc (garbage collection) command cleans these up. This command:

1. Compresses objects.
2. Cleans up orphaned data (like unreachable commits or branches).
3. Enhances performance.


> Remarkable to know that some commands will do built-in auto `gc`
> the following commands do that:  
> 1. git commit
> 2. git merge
> 3. git pull
> 4. git rebase

Although these commands perform built-in cleaning, it's still recommended to run git gc manually from time to time. Some DevOps teams automate this process in their CI/CD pipelines after every release.  

# Managing Large Files:
When you add a file to Git, it stores the file in its database along with metadata for tracking. For very large files (e.g., in the gigabytes range), this process can be costly, which is why Git limits the size of uploaded files. For example, GitHub’s file size limits are as follows:

| Product | Max file size |
| -- | -- |
| GitHub Free |	2 GB |
| GitHub Pro | 2 GB |
| GitHub Team	| 4 GB |
| GitHub Enterprise Cloud	| 5 GB| 

To manage large files effectively, Git offers an extension called [Git Large File Storage](https://git-lfs.com/). Instead of storing large files in the Git database, LFS stores them externally and tracks them using lightweight pointers in Git.  

### How to use Git LFS?
After downloading and installing Git LFS, enable it by running:

```bash
git lfs install
```

You can then configure specific file types to be tracked by LFS, for example:

```bash
git lfs track "*.pdf"
```
From this point, any PDF files will be handled by LFS.

# Permanently Deleting Files from Git History and Purging Repositories

Sometimes, a sensitive file (like credentials) or a large, unnecessary file gets committed by mistake. In such cases, you'll need to permanently remove it from the Git history. Additionally, you may want to purge a repository’s old, unneeded branches and tags to reduce its size.

To handle these tasks, two tools can rewrite Git history: 

* git filter-repo
* BFG Repo-Cleaner

> Important: These tools rewrite the repository history. Be sure to close any open pull requests first, as the PRs may break after the history changes.


### Using BFG Repo-Cleaner

The BFG Repo-Cleaner specializes in removing unwanted files from a Git repository. It's faster and simpler than `git filter-repo`, but it is more limited, focusing only on file deletion and text replacement.

To use it:

```bash
# create bare repository
git clone --mirror git://github.com/<username>/myrepo.git

# delete the required file
java -jar bfg.jar --delete-files <path to files>

# or replace text in a file, which will arease all data
java -jar bfg.jar --replace-text <path to files>

# then clean your local reflog from those orphan entries
git reflog expire --expire=now --all
# and run garbage collection to prune all orphan entries from the repository
$ git gc --prune=now --aggressive
# then you need to push with force the cleaned repository back
git push --force

```

This process alter the repo's history, which means will change the SHAs for that commit you are altering, and will change all its child and dependent commits.  
So before doing that, make sure to close any pull requestes in your repository.

BFG and other tools that will change the history will work on bare repository




### Using git filter-repo

[git-filter-repo](https://github.com/newren/git-filter-repo) is a more comprehensive tool for rewriting Git history, purging unwanted data, and trimming repository size. It’s more versatile than BFG and handles many complex use cases.


# Dealing with Large Repositories:

If your team works with a large repository, you may need a solution to improve performance without sacrificing history. The best tool for this is [Scalar](https://github.com/microsoft/scalar/), developed by Microsoft after managing their massive Windows repository.  

Scalar is built on top of [`VFS For Git`](https://github.com/microsoft/VFSForGit), or **`Virtual File System For Git`**, and still uses this technology under the hood.  

Scalar works seamlessly with large repositories by using a combination of Git LFS and efficient file tracking systems.  
Scalar includes a background service that runs on developer machines to monitor and sync repositories, keeping them healthy and up-to-date. It requires a Git service provider that supports the GVFS protocol, such as GitHub or Azure Repos.   

# Automatically Generating a Changelog for Releases

During development, your team adds new features, fixes bugs, and commits meaningful messages. When it's time for a release, you'll want a summary of these changes. A common approach is to create a `CHANGELOG` file.

You can use `git log` to list changes since the last release:

```bash
git log <tag-or-branch-of-last-release>..<current-tag> 
```
However, this output can be noisy. Two tools can help generate cleaner, more useful changelogs:

* gitchangelog
* github-changelog-generator

### gitchangelog
[gitchangelog](https://pypi.org/project/gitchangelog/) is a python tool that parses commit messages using a defined pattern to create a well-organized report from Git logs.

### github-changelog-generator
[github-changelog-generator](https://github.com/github-changelog-generator/github-changelog-generator) is a Ruby tool that generates changelogs by parsing pull request messages on GitHub.

