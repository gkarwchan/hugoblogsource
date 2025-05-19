+++
title = "Simplify Jupyter Projects with Docker"
date = 2025-05-19T18:41:54-06:00
short = true
toc = true
draft = false
tags = ["python"]
categories = []
series = []
comment = true
+++


Managing multiple Jupyter Notebook projects often means juggling different Python libraries and dependencies. Instead of setting up a separate virtual environment and installing Jupyter for each project, I use **Docker** to streamline the process.

## Why Use Docker for Jupyter Notebooks?

Docker offers the same level of environment isolation as virtual environments, but with several added benefits:

- Pre-packaged with all required dependencies.
- Clean, reproducible environments.
- No need to install Jupyter separately for every project.

While tools like `conda` can also handle environment management, I personally find Docker more reliable and easier to work with.

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

## What about .env file:
I include a .env file in the root directory to securely store my API keys for services like GPT, Claude, and others.

### Project Structure
Your project directory might look something like this:

```bash
my-jupyter-project/
├── docker-compose.yml
├── .env
└── notebooks/
    └── your_project.ipynb
```

## Conclusion
With this setup, you can quickly spin up isolated environments for your Jupyter projects without redundant installs or configurations.