+++
title = "Managing Credentials for Azure Artifacts"
date = 2024-12-17T18:41:54-06:00
short = true
toc = true
draft = false
tags = ["azure", "devops", "dev tools"]
categories = []
series = []
comment = true
+++

When storing your private artifacts (NuGet, NPM, Docker, etc.) in Azure Artifacts, authentication is required to access them. Various tools such as dotnet, nuget, msbuild, and Visual Studio may need to retrieve these artifacts during the build process. To simplify credential management across these tools, Microsoft provides the Azure Artifacts Credential Provider.

# Introduction & Underlying Technology
Since accessing NuGet packages requires authentication, Microsoft provides the Credential Provider, a NuGet plugin that automates credential acquisition for NuGet clients, including:

* dotnet.exe
* nuget.exe
* msbuild.exe
* Visual Studio

The Credential Provider is a cross-platform authentication tool built on [the NuGet Cross-Platform Plugins model](https://learn.microsoft.com/en-us/nuget/reference/extensibility/nuget-cross-platform-plugins). It follows the same principles and architecture as the NuGet Authentication Plugin.  

Let's talk about those underlying technologies:    

### NuGet Cross Platform Plugins Model:
In NuGet 4.0+ a new plugin extensibility model was designed.  
The plugins are self-contained executables (runnable in .NET core world), that the NuGet client launch in a separate process.  

> "Why .NET Core?  
NET Core enables cross-platform execution, making it an ideal runtime environment for the plugins."

### NuGet Cross Platform Authentication Plugin.
NuGet feeds and providers could be secured storage that require authentication like: 
* Pakage Mangement of VS Team Service.
* MyGet
* and others

This plugin was built to provide authentication service for all the NuGet clients for all types of feeds.  

### Azure Artifact Cernential provider
The Azure Artifacts Credential Provider builds upon the same principles and technologies as the NuGet Authentication Plugin. By understanding these underlying technologies, we can better grasp how the Azure Artifacts Credential Provider operates.

# How NuGet Plugin works
The high level workflow can be described as:
1. NuGet discovers available plugins.
2. when applicable, NuGet iterate over the plugins in priority order.
3. NuGet will use the first plugin that can service the request.
4. The plugin will be shutdown when it is done.

### Plugin Installation and discovery
A convention based plugin discovery was added in Plguin version 2.0, and it is based on file system, but for backward compatibility with older version the location was determined by environment variable, so that behavior is still supported.  
We are going to list the plugin discovery rules by its priority.  

1. Environment variables:
If `NUGET_PLUGIN_PATHS` is set then it takes precedence. The variable should contains the full path of the executables exe in .NET framework, or the .dll in .NET Core.
2. User-Location: the user location is: 
    1. for .NET Core: `%UserProfile%/.nuget/plugins/netcore`
    2. for .NET Framework: `%UserProfile%/.nuget/plugins/netfx`
```
.nuget
    plugins
        netfx
            CredentialProvider.Microsoft
                CredentialProvider.Microsoft.exe
                nuget.protocol.dll
        netcore
            CredentialProvider.Microsoft
                CredentialProvider.Microsoft.dll
                nuget.protocol.dll
```    
3. Predetermined location in VS and dotnet: 
    1. for dotnet it is: \Program files\dotnet\sdk\\{sdk-version}\Plugins
    2. for VS: Program Files\Microsoft Visual Studio\version\Common7\IDE\CommonExtensions\NuGet\Plugins.


# Usage
The usage depends on what tool is using it.  
With all tools, on its first usage the plugin will aquire a token and then store it in a cache location, and all subsequent calls will check if that store has a valid token and use it.  
The credential cache location is:  

* windows: `$env:UserProfile\AppData\Local\MicrosoftCredentialProvider`
* Linux\MAC: `$HOME/.local/share/MicrosoftCredentialProvider/`

### dotnet
dotnet is not an interactive tool by default, so on the first time usage you need to inforce the interactive using the following command:
```bash
dotnet restore --interactive
```
Once you aquired a token, you can run authenticated commands without `--interactive` for the lifespan of the token which is saved in a cache location.  


### nuget
the nuget client is an interactive client, so it will prompt for authenticateion and it stores them in the same above location. In Windows, if you are already Azure DevOps, Windows Integrated Authentication maybe used to get automatically authenticated.

### msbuild
As dotnet, the first time you use msbuild, you should use the flag `/p:nugetInteractive=true` switch.
```bash
msbuild /t:restore /p:nugetInteractive=true
```

### Anattended build agents
for CI build agents like Azure Pipelines and Teamcity you can do the following:

1. for Azure DevOps pipeline there is a special task [NuGet Authenticate](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/nuget-authenticate-v1?view=azure-pipelines&viewFallbackFrom=azure-devops)
2. for others you can supply the token directly using `VSS_NUGET_EXTERNAL_FEED_ENDPOINTS` environment variable.

### Docker containers
[Managing NuGet Credentials in Docker scenarios](https://github.com/dotnet/dotnet-docker/blob/main/documentation/scenarios/nuget-credentials.md#using-the-azure-artifact-credential-provider)

### Environment variables:
The credential provider accepts a set of environment variables, not all of them should be used in production.  
* NUGET_CREDENTIALPROVIDER_SESSIONTOKENCACHE_ENABLED: controls whether or not the session token is saved to disk. if false the Provider will prompt for auth every time.
* VSS_NUGET_EXTERNAL_FEED_ENDPOINTS: JSON that contains an array of username, access tokens and endpoints to authenticate endpoints in nuget.config.
* ARTIFACTS_CREDENTIALPROVIDER_FEED_ENDPOINTS: Json that contain config data to authenticate Azure Artifacts feed

# Help and troubleshoot
The windows plugin, delivered in `netfx` folder, ships with a stand-alone executable that will acquire credentials. This program will place the credentials in the same location that the .dll would if it were called by dotnet or nuget.  
The command will provide help context on how to use the tool.  
