+++
title = "Enhancing Team Collaboration with a Git Forking Strategy"
date = 2024-09-23T18:41:54-06:00
short = true
toc = true
draft = false
tags = ["devops"]
categories = []
series = []
comment = true
+++

The fork-based pull request (PR) workflow is widely used in open-source projects because it enables external contributions while keeping the core repository secure and controlled by a designated team.  

# Fork-baed workflow and Inner Source

Typically, only contributors with repository access can create pull requests. As a contributor, you can create branches, submit PRs, and request merges. However, what happens if you're not part of the repository's team, as is the case in open-source projects?

Let’s consider this scenario:
Imagine you're part of *Team A*, working on a project that relies on another project maintained by *Team B*. You've identified a small bug in Team B's code, and you need a quick fix. Unfortunately, *Team B* is swamped and can’t address the issue immediately. This is where Inner Source (also called internal open source) becomes incredibly useful.

Inner Source applies open-source collaboration practices within an organization, enabling teams to contribute to each other’s codebases without direct ownership. This approach brings the collaborative spirit of open-source into your company, fostering greater flexibility and efficiency across teams.

# Implementing a Fork-based Workflow

In a fork-based workflow, *Team A* is given read-only access to *Team B*’s repository. From there, the process unfolds as follows:  

1. Fork the Repository: Team A creates a fork of Team B’s repository.
2. Make the Changes: Team A applies the necessary fixes or updates directly in their fork.
3. Test and Validate: Team A runs tests and continues their work without waiting for Team B to make the changes.
4. Submit a Pull Request: Once ready, Team A submits a PR from their fork to the original repository.
5. Team B Reviews the PR: Team B can review the PR at their convenience, either approving it or making further changes as necessary.

This process allows Team A to make timely contributions without being blocked by Team B’s schedule or requiring direct access to their repository.

# Useful Commands and Tips for Managing Forks:  

To manage forks efficiently, here are some helpful commands and tips:

### Creating a fork:

While the easiest way to fork a repository is via the web interface, you can also use the `GitHub CLI` for a command-line approach: 

```bash
# create a fork under your username
gh repo fork <source-repository-url> 

## Rename your fork copy
gh repo fork <source-repository-url> --fork-name <new-name>

# create the fork under an organization name
gh repo fork <source-repository-url> --org <org-name>
```

### Keep your fork Up-To-Date 

After forking a repository, you’ll want to ensure your fork stays synchronized with the original project. Here’s how to do it:

```bash
# clone it locally
git clone <your-fork-url>

# you can as well while creating the fork, clone it locally
gh repo fork <original-repository-url> --clone

# add a remote to the original repository
git remote add upstream <original-repository-url>

## fetch the latest changes from upstream main branch
git fetch upstream main

# rebase from upstream main branch
git rebase upstream/main
```

This workflow makes it easier for multiple teams to collaborate on interdependent projects, ensuring efficient and flexible development without waiting on others. By adopting Inner Source practices, you foster cross-team collaboration and bring the benefits of open-source development inside your organization.


