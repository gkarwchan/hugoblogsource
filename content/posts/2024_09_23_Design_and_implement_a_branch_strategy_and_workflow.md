+++
title = "Design and implement Git branching strategies for CI/CD integration"
date = 2024-09-23T10:41:54-06:00
short = true
toc = true
draft = false
tags = ["devops"]
categories = []
series = []
comment = true
+++

Establishing a standardized development process that integrates a Git workflow with Continuous Integration/Continuous Deployment (CI/CD) is crucial before writing any code. This post will explore a widely-used approach: the Trunk-Based Development Workflow, which is adopted by many leading companies, including Microsoft.

# Choosing a branching strategy:

Every team should adopt a consistent code release process to maintain quality and reduce risks. This starts with selecting a Git workflow, continues through integrating CI/CD, and culminates in defining a release strategy.  

In this post, we’ll focus on the Git workflow, starting with the basic steps of a typical release flow: creating branches, pushing changes, submitting pull requests, and merging code.  

Choosing the right Git workflow for your team can significantly boost productivity. Consider the following when selecting the best strategy for your team:

* Scalability: Will this workflow scale as the team grows?
* Error Recovery: How easy is it to recover from mistakes?
* Overhead: How much additional work, such as resolving merge conflicts or waiting on CI/CD, will the workflow introduce?

# What is Trunk-Based Development?:

The core principle of [Trunk-based Development Workflow](https://trunkbaseddevelopment.com/) is that all development work happens directly on the main branch (commonly called “trunk” or “master”). This method encourages continuous integration, with developers frequently committing small, incremental changes. Automated testing and integration play a pivotal role in maintaining high code quality.

Notably, Microsoft uses this workflow internally, and it's a slight variation of the [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow).

### Branching:

For every new feature or bug fix, a developer creates a dedicated branch. Once the work is complete, this branch will be merged into the trunk via a pull request.

### Pull Request with review policies:
After completing their work, developers submit a pull request (PR) to merge their branch into the trunk. Direct check-ins to the trunk are not permitted—merging must happen through a PR.
  
To ensure code quality, additional policies can be enforced on PRs:

Mandatory code reviews by other developers
* All PR comments must be resolved
* CI/CD builds must pass all tests (unit tests, code scanning) before merging
* This process safeguards the integrity of the codebase while maintaining a consistent flow of changes.

### Releases and Release branches:
When it’s time to release code to production, a `Release branch` is created. This branch is then deployed to production.

If a bug is found in production, the fix is made on the trunk using the same process: a bug-fix branch is created, a PR is submitted, and after merging into the trunk, the fix is `cherry-picked` into the release branch for deployment.

![Branch Release](/img/branch-strategy.png)


### Branche policies and permissions:
The Trunk-Based Development workflow allows for the enforcement of policies to enhance security, code quality, and team efficiency.

##### * Branch hierarchy and permissions
A structured branch hierarchy can help maintain organization and control. For instance, user-created branches could reside in `/users` or `/features`, while release branches live under `/releases`. Permissions can be set accordingly—only administrators would have the authority to create or modify release branches.

##### Enforcing Branch policies:
To further ensure code quality, the following policies can be applied to the trunk and release branches:

* Mandatory Code Reviews: Every PR must be approved by another developer before it can be merged.
* Successful Builds: CI processes ensure that a PR’s build passes unit tests or code scans before allowing a merge.
* CD Automation for Releases: Creating a release branch can trigger automated deployment to a pre-production environment, along with performance and stability checks.
