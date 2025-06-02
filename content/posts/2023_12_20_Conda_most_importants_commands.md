+++
title = "Survive commands with Conda"
date = 2023-12-20T12:41:54-06:00
short = true
toc = true
tags = ["python"]
categories = []
series = []
comment = true
+++

I had a [previous post]({{< relref 2018_08_22_Python_Virtual_Environments >}}) on how to setup virtual environments using **pipevn**, and **virtualenv**.  
But Conda is more robust and useful, and now I am using it for all my projects.  

## Conda and the Shell
While you install Conda, it will ask you at the end if you want initialize conda from the shell environment.  
The question is something like this:  
```
Do you wish the installer to initialize Anaconda3 by running conda init? [yes|no] [no] >>>" Stack OverflowGitHub
```
If you answer yes, and you want to keep your shell clean, but you want to add temporarley Conda to your path, run this:
Otherwise let's talk about some useful command

```bash
# run this to initialize conda and activate base environment everytime
miniconda/bin/conda init

# to just initialize conda but not the base environment then run this
conda config --set auto_activate_base false

# to reverse the whole initialization and keep your shell clean then 
conda init --reverse $SHELL

# if you have nothing in your shell and you just want to initialize conda without base enviornment
source miniconda3/etc/profile.d/conda.sh

```
## Manage Conda environments

```sh
# to see all environments
conda info --envs
conda env list

# to create an environment with paython version
conda create --name env-name python=3.9

## to create an environment from an environment file
## --name is optional and can be set from the file
conda create --file env-file.yml --name env-name


## to update an environment from environment file
## if the environment is alreeady activated, no need to set the name
## prune if you want to remove some packages
conda env update --file env-file.yml --name env-name --prune
```
