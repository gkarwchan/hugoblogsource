---
title: Introducing Kudu, the engine that handle all web application deployment to Azure App Service.
date: 2023-02-01T20:20:40-07:00
tags: ["devops", "azure"]
---

If you follow any tutorials on Azure App Service, you will find that they use one of five options to deploy a web application to the Azure.  
1. Using Azure DevOps
2. Using Github actions and webhooks.
3. FTP
4. Zip Deploy.
5. MSDeploy (Microsoft Web Deploy tool).

But behind the scenes, all these options are using the same back engine, which is [Kudu](https://github.com/projectkudu/kudu).

When we use FTP, Zip, or MSDeploy, we are actually calling Kudu REST API for deployment.  

## How it works:
When we create an Azure App Service, we create an associated **`scm`** service for Kudu service, and other extensions.  
To access those services we ass `scm` to the url as follows:  
```
# if the URL of our website is:
https://mywebsite.azurewebsites.net
# then the scm will be available on 
https://mywebsite.scm.azurewebsites.net
```
To verify this, just run the following command to get the deployment profiles for your app service

```bash
az webapp deployment list-publishing-profiles --resource-group <rg-name> --name <app-name>
```
You will get a json with at least three publishing profiles.  
For an App service that we didn't create any Github actions or Azure DevOps, then they already have the three built-in publishing profiles:  
* FTP
* ZipDeploy
* MSDeploy (which is Web Deploy)

The output of previous command will be:

```json

  {
    "destinationAppUrl": "https://mywebsite.azurewebsites.net",
    "profileName": "mywebsite- Web Deploy",
    "publishMethod": "MSDeploy",
    "publishUrl": "mywebsite.scm.azurewebsites.net:443",
    "userName": "$mywebsite",
    "userPWD": "..."
  },
  {
    "destinationAppUrl": "https://mywebsite.azurewebsites.net",
    "ftpPassiveMode": "True",
    "profileName": "mywebsite - FTP",
    "publishMethod": "FTP",
    "publishUrl": "ftps://waws-prod-blu.ftp.azurewebsites.windows.net/site/wwwroot",
    "userName": "mywebsite\\$mywebsite",
    "userPWD": "..."
  },
  {
    "destinationAppUrl": "https://mywebsite.azurewebsites.net",
    "profileName": "mywebsite- Zip Deploy",
    "publishMethod": "ZipDeploy",
    "publishUrl": "mywebsite.scm.azurewebsites.net:443",
    "userName": "$mywebsite",
    "userPWD": "..."
  }
```

ZipDeploy and MSDeploy are very similar by using the same publishing URL, but they are different of the zip file that is posted.  
ZipDeploy can be achieved by generate a normal zip file for all the artifacts.  
MSDeploy is using a special zip that is generated by Microsoft tool (Web Deploy) or MSBuild tools.  

### But what about Powershell or CLI deployment?
We know that both Azure CLI, and Azure powershell have the ability to do deployment.  
For example on Azure CLI we have the following:

```bash
az webapp up --name az204app23690dd
```

This actually is calling `zip deploy` behind the scene.  
And to prove that, let us deploy an application with the previous command, and you will see the following output from the command:

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qx3v07ewy0qsvwr0080m.jpg)

As you see, the CLI is using zip deploy behind the scene, and it is doing the following:  

1. creating a zip content
2. getting `scm site` credentials for the app service.
3. run zip deployment.
