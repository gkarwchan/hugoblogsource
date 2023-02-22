---
title: Take your development environment anywhere and on any machine with Dev Containers
date: 2022-12-29T19:51:56-07:00
tags: ["asp.net", "container", "dev tools"]
---

[Dev containers](https://containers.dev/) provides a fantastic way to onboard a new developer up and running in matter of just clone the git repository.  

Dev containers allow you to create a docker container that will host all the development tools and libraries you use in your projects, and run it inside the container, and if you have an editor compatible then you can make the IDE connect to the containers and you can run or debug your code inside the containers.  And even if you don't have a compatible IDE, then you can run it inside [github's codespaces](https://github.com/features/codespaces), which is compatible with Dev container.

## How to setup Dev container?
All you need is to create a json file called **`devcontainer.json`** and an optional Dockerfile, which you add all your tools, software, and libraries (for example dotnet SDK, SQL server, redis...)

## How developers use it?
A new developer only needs a compatible IDE installed on their machine, and docker desktop of course.  
Even a developer can work on github's codespaces, and this way they can take their environment anywhere they want, and on any machine.  
Right now the only IDE that work with dev containers are Microsoft Visual Studio Code, and Visual Studio, but that might change with time.  

## How to create a dev container?
1. in your root folder of your project, create a subfolder called **`.devcontainer`**.
2. In that folder create a file called **`devcontainer.json`**.
3. the content off the file devcontainer.json will specify what tools, libraries you use.  

To create the file you have two options:  
1. start from a predefined templates, and add libraries later.
2. Or you build your own environment from scratch.  

#### Predefined templated: 
There are already of the shelf Dev docker images for common development environment. For example there is one for dotnet, and other for Java, and other for Node.  
For a list of the pre-built templates [check here](https://containers.dev/templates).  
Using a pre-built dev container doesn't mean you are only limited to that image, because you can still add other tools, which they are called **`features`** to that image.  
, and for the other `features` that you can add [check this](https://containers.dev/features).  


You don't need a Docker file, unless you want to build your dev environment step by step.  

For example, I am going to build a dev container for dotnet sdk 6, with Azure cli, and bash command.

```json
{
    "name": "my dotnet development",
    "image": "mcr.microsoft.com/devcontainers/dotnet:0-6.0",
    "features" {
        "ghcr.io/devcontainers/features/azure-cli:1": {},
	"ghcr.io/devcontainers-contrib/features/bash-command:1": {}
}
```
For a detailed attributes and syntax for this file, [refer to this document](https://containers.dev/implementors/json_reference/).  

If you prefer to build your own environment from scratch, then you should write a docker file, and in that case your devcontainer.json file will look like:  

```json
{
    "name": "my dotnet environment",
    "build": {
       "dockerfile": "Dockerfile"
    }
}
```

And you provide a docker file in the same folder `.devcontainer`.

## How to use dev containers?
All what you need to use a dev container is an IDE that support them, and right now the only IDE that support them are:  
* Visual Studio Code
* Visual Studio

Or alternatively you can use github's codespaces, and then you can run your code from any browser on any device.  
For visual studio code, you need to install [an extension to run create and integrate with dev containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).  
When you open a folder that contains a dev container, VS code automatically prompt you an option to open the folder to develop in container.

![Visual studio code prompt for dev container](![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/dcfdwoh1uqkwokdcuzhe.jpg)
