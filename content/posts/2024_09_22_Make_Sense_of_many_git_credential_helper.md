+++
title = "Enhancing Your Git Workflow with Git Credential Manager Core"
date = 2024-09-22T10:41:54-06:00
short = true
toc = true
draft = false
tags = ["devops"]
categories = []
series = []
comment = true
+++

Git’s credential helper is a handy tool that saves your credentials, so you won’t need to re-enter your username and password for every `git pull` or `git push`. However, depending on the age of the tutorial you're following and the platform you're using, the instructions for setting up credential storage may vary.

In August 2021, GitHub introduced a new cross-platform tool called the [Git Credential Manager Core](https://github.blog/open-source/git/git-credential-manager-core-building-a-universal-authentication-experience/). Let’s explore how this tool can streamline your team’s workflow.


## Before Git Credential Manager Core:

Historically, Git offered several options for managing credentials, which you can see [their list here](https://git-scm.com/doc/credential-helpers), and we’ll briefly review:


#### Git Credential Store:

Before `Git Credential Manager Core`, the only cross-platform option was [**`Git Credential Store`**](https://git-scm.com/docs/git-credential-store), which stores the credentials as plain-text.  
With the rise of two-factor authentication (2FA), this method became obsolete since it could not handle 2FA.

#### Platform-Specific Encryption Store:
Credential storage methods that used encryption were platform-specific, relying on the operating system’s native encryption capabilities. These included:

* git-credential-osxkeychain for Mac: which use Mac's keyChain to store the credentials.
* git-credential-libsecret for Linux: which use Linux secret service.
* git-credential-wincred for Windows: which use Windows Credential Manager.
* deprecated [Git Credential Manager for Windows](https://github.com/microsoft/Git-Credential-Manager-for-Windows): This tool was deprecated after the Core one was created, and it is no longer maintained.

#### Other special stores:
There are two stores that are less used:  

* git-credential-cache (not for windows): which stores the credential in memory for 15 minuntes.
* git-credential-oauth for Linux: which use OAuth authentication.

## The arrival of Git Credential Manager Core:

As mentioned above, there wasn’t a single tool that could both encrypt credentials and work across all platforms—until [`Git Credential Manager Core`](https://github.blog/open-source/git/git-credential-manager-core-building-a-universal-authentication-experience/) was introduced. This tool addresses both of these needs: it's cross-platform and encrypts credentials securely.

Although it was created by GitHub, it has since been adopted by the broader Git community and integrated into Git installations for Windows as well.

## How to set it up.
If you installed git on your machinge with version 2.39 and later, then you installed that tool by default.  
To know if you have that tool, check the following:  


```bash
git config --global credential.helper
## the output depend on the version you use

# for Git 2.38.1 on Windows , core was called manager-core
credential.helper=manager-core

# Git 2.39+ core replaced Windows manager and it took its name : manager
credential.helper=manager
```

If the tool you are using is not one of the above, then you can change it as follows:

```bash
# For Git versions up to 2.38.1 on Windows, the credential helper was called manager-core
git config --global credential.helper manager-core

# Starting from Git 2.39+, the helper was renamed to 'manager'
git config --global credential.helper manager
credential.helper=manager
```

By configuring Git Credential Manager Core, you ensure a smoother, more secure authentication experience, freeing up time to focus on what matters most: coding.
