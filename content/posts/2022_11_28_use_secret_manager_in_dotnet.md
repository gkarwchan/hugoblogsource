---
title: Using Secret Manager for Configuration in .NET
date: 2022-11-28T19:41:04-07:00
tags: ["asp.net"]
---

It is critical not to store passwords or API keys in our code.  
For all environments for the development process: (QA, UAT, Pre-Production, and Production), it is easier to place it in a safe place (Azure Key Vault for example), and access it during deployment.  
For developer machines, we can use `Secret Manager`, or sometimes called `User Secrets`, which has a built-in support in `ASP.NET`.  

&nbsp;

## Enable Secret Storage:
In the project you want to add a secret run this command:  
```bash
dotnet user-secrets init
```

This will generate a secret file, which is a json file called `secrets.json`, in a folder with a GUID generated name.  
The location of the folder is

|Operating System|Location|
|---|---|
|Windows|%APPDATA%\Microsoft\UserSecrets\<user_secrets_id>\secrets.json|
|Linux/MacOS|~/.microsoft/usersecrets/<user_secrets_id>/secrets.json|

And that generated GUID will be added to the project file **`.csproj`** as follows

```xml
<UserSecretsId>d87e6676-57eb-45c8-98d4-c6a3be58debb</UserSecretsId>
```
&nbsp;

## Add a key secret ##
Let's supposed we want to add a key-api for google-map, where the `appsettings.json` file the entry will look like:

```json
  "googleMapApi" : {
    "apiKey": "Enter anything here",
    "apiUrl": "https://maps.googleapis.com/maps/api/json?"
  }
```
To add that, we run the following command line

```bash
dotnet user-secrets set "googleMapApi:apiKey" "<real key goes here>"
```
## Access a secret in ASP.NET ##
For **ASP.NET** application, the `WebApplicationBuilder` add most of the configuration providers that are used by developers like environment variable provider, appsetting provider, command-line provider, and last but not least the user secret provider.  
So, in ASP.NET you access it as any other configuration setting using **`IConfiguration`** injected by DI:

```csharp

// pass this to the constructor to be injected by DI
private readonly IConfiguration _configuration;
// and then inside the controller

var key  = _configuration["googleMapApi:apiKey"]
// or the following:

var key = _configuration.GetSection("googleMapApi")["apiKey"];

```  
&nbsp;


## Access a secret in console application ##

.NET console application don't provide built-in capability to read the user secrets or even any configuration provider, and we have to add that ability by adding the respective packages.  
Add the following packages for a console app:

```bash
dotnet add package Microsoft.Extensions.Configuration
dotnet add package Microsoft.Extentions.Configuration.Json
dotnet add package Microsoft.Extensions.Configuration.UserSecrets
```

and then add the following code
```
var configBuilder = new ConfigurationBuilder()
    .AddJsonFile("appsettings.json", false, true)
    .AddUserSecrets(Assembly.GetExecutingAssembly(), true); 
var config = configBuilder.Build();   

// then access it as follows
var key = config["googleMapApi:apiKey"];
```

And then you can access it as you access in ASP.NET
