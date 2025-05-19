+++
title = "Jupyter Notebook startup projects"
date = 2025-05-19T18:41:54-06:00
short = true
toc = true
draft = false
tags = ["python"]
categories = []
series = []
comment = true
+++

I use Jupyter notebook in many tutorial projects, and each projects require different libraries.  
Instead of creating a virtual evironment for each project, and for each evnironment I install Jupyter notebook, I use docker.  

# Benefits of using Docker.
It is providing the isolation that the virtual environment has, and it has already all required packages.  
You can still do that with `Conda`, but presonally I feel more comfortable around docker.  

# The YAML file for docker compose:
I have this simple YAML file, which pull the required image, and create a volume to share data with.  

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

I added a `.env` file that has my API keys for all external services, like gpt, claude ...etc.

# file structure

```bash
my-jupyter-project/
├── docker-compose.yml
├── .env
└── notebooks/
    └── your_project.ipynb
```
