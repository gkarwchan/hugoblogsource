+++
title = "Simplify Jupyter Projects with Docker or Conda"
date = 2025-05-18T18:41:54-06:00
short = true
toc = true
draft = false
tags = ["python"]
categories = []
series = []
comment = true
+++


Managing multiple Jupyter Notebook projects often means juggling different Python libraries and dependencies. Instead of setting up a separate virtual environment and installing Jupyter for each project, I use **Docker** to streamline the process.  
We can use **Conda** as well, and I will show how, but presonally I prefer Docker.

## Create an isolated evivronment for each project

I had a [previous post]({{< relref 2018_08_22_Python_Virtual_Environments >}}) on how to setup virtual environments using **pipevn**, and **virtualenv**.  
But since that time, I switched to use mostly **conda** or **docker** specially for Jupyter notebooks.  

Conda offers managing virtual environments, and if you want a tool just to create virtual environments, and install packages, then in my opinion, Conda is the best between others uv, venv, virtualenv, pipenv ...etc.  
Docker offers the same level of environment isolation as virtual environments, but with several added benefits:

- Pre-packaged with all required dependencies.
- Clean, reproducible environments.
- No need to install Jupyter separately for every project.

## Docker Compose Setup

Here’s a minimal `docker-compose.yml` file I use. It pulls a base Jupyter image and sets up shared volumes for your notebooks and environment variables.

```yaml
version: "3.8"

services:
  jupyter:
    image: jupyter/minimal-notebook
    container_name: jupyter_tutorial
    ports:
      - "8888:8888"
    volumes:
      - ./notebooks:/home/jovyan/work
      - ./.env:/home/jovyan/.env
    environment:
      - DOTENV=/home/jovyan/.env
    command: start-notebook.sh --NotebookApp.token=''
```

#### What about .env file:
I include a .env file in the root directory to securely store my API keys for services like GPT, Claude, and others.

#### Project Structure
Your project directory might look something like this:

```bash
my-jupyter-project/
├── docker-compose.yml
├── .env
└── notebooks/
    └── your_project.ipynb
```

## Conda Template Environment
Conda provide different ways to create an environment with base packages. You can create a base environment and then clone it, or you can create a **Template Environment**, as follows:  

#### 1. Create the template environment

```bash
conda create -n jupyter-template python=3.11 jupyterlab notebook ipykernel
```

#### 2. export the environment to yaml file

```bash
conda activate jupyter-template
conda env export --no-builds > jupyter-template.yaml
```

#### 3. Use the template to create a new environment

```bash
conda create -n my-new-project --file jupyter-template.yaml
```

#### Or Create the template YAML manually

If you want to create the file manually, there it is:

```yaml
name: jupyter-base
channels:
  - defaults
dependencies:
  - python=3.11
  - notebook
  - jupyterlab
  - ipykernel
```

and then you can use it as follows:

```bash
conda env create -f jupyter-template.yaml -n my-new-env
```

## Another alternative: Python docker:
Another alternative, is just using python docker image/container, and create a new container for each project:

```
docker run -it --rm python:3.11 bash
```

## Other virtual environment tools:
Although there are other virtual environment tools, like uv, venv, virtualenv, poetry.  
Some of them are more for packaging production code, like **poetry**, and some are mimicking npm like 
**pipenv**, and some of them are fast like **uv**. But personally I think Conda (specially miniconda) is the easiest to use.  
You can get more [here]({{< relref 2018_08_22_Python_Virtual_Environments >}}).  

## Conclusion
With this setup, you can quickly spin up isolated environments for your Jupyter projects without redundant installs or configurations.