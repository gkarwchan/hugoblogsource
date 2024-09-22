+++
title = "Design and implement Git branching strategies and workflow"
date = 2024-09-23T10:41:54-06:00
short = true
toc = true
draft = false
tags = ["devops"]
categories = []
series = []
comment = true
+++

Adopting a standardized development process for Git workflow, and how it integrate with CI/CD is the first step you should establish in your team before writing one line of code. We are going to cover one major well known workflow called `Trunk-based workflow` that is used by many companies, including Microsoft.  

# Chose a branching strategy:

Every organization should settle on a standard code release process to ensure consistency, and reduce risks. The code release strategy start from adopting Git workflow, and include building CI/CD process and end with building a release strategy.  
We are going to cover in this post the Git workflow, and start from the the basic steps of the release flow: branch, push, pull request, and merge.

Chosing the right Git workflow for your team can enhance the team effectiveness and increase its productivity. To chose the correct strategy there are some considerations:  

* Scalability: does this workflow scale when the team expand in size.
* Undo mistakes: how easy it is to undo mistakes and errors?
* Overhead works: how much overhead work (like fixing merge conflicts, or waiting for CI/CD process), this workflow will add to the team.

# Trunk based workflow:

The core idea behind the [Trunk-based Development Workflow](https://trunkbaseddevelopment.com/) is that all development work takes place directly on the main branch (often called "trunk" or "master"). This approach emphasizes continuous integration, with developers frequently committing small, incremental changes to the main branch. Continuous integration and automated testing play a crucial role in maintaining code quality and stability.
It is good to say that Microsoft adopt this workflow for its internal development.  
Trunk-based workflow is a slight modification on [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow).

### Branching:

Every bug or feature will have its own branch. A developer will create a new branch for each feature or bug is working on.

### Pull Request with review policies:
After the developer finish from their development, they will create a `pull request` to merge it into trunk. No direct check-in into trunk without a PR.  
This process of allowing merging code into trunk by only PR will protect the code quality, specially if you add more policies, like the PR must be approved by other developers, and all comments in the PR must be resolved, and the PR triggers CI build, and all quality checks (unit tests and code scanning) must pass before the developer can merge its work into the trunk.

### Creating Releases and Release branches:
When time comes to creating a release and ready for production, we create a `Release branch`.  
A release branch will be created and will be deployed to production.  
In case a bug was found in prodution, then the bug will be fixed into the trunk (following the same process of create a bug branch and then create a PR), and after it is merged into trunk, we `cherry-pick` into the release branch.  
![Branch Release](/img/branch-strategy.png)


### Branche policies and permissions:
The above workflow will allow to add policies to increse the protection, security and quality of the code.

##### Branch hierarchy and permissions
We can have a standard hierarchy of branches, and give them permissions, like for example all user created branches will be under folders like `/users` or `/features`. Release branches will be under `/Releases`, and only administrators can create those branches. 

##### Branch policies and forcing PR:
We can add branch policies to enhance the quality of the code by forcing PR to add code to the trunk, and on that PR we can add protection rules, for example:

* add mandatory code review: So every PR must be approved by others to allow to merge.
* add check successful build on PR to allow it to be merged: so we can run CI process and check the quality of that build (unit test or code scanning tools).
* add CD status on release branches: so create a release branch triggers a CD process to deploy to pre-environment, and can trigger a process of checking performance and stability of the release.

