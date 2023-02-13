---
title: Deploy A Single Page Application to Azure Static Webapp using TeamCity, Jenkins or any CI, or command line
date: 2023-01-03T19:56:30-07:00
tags: ["azure", "azure static web app", "ci/cd"]
---

I was trying to setup a deployment for an SPA application to an Azure Static Web app using TeamCity, but most of the tutorials I found was doing the deployment through CI/CD of Github's Actions by monitoring a specific branch of a Github repository and deploy automatically whenever we check in into that branch, or the other alternative is using Azure DevOps pipeline.
But what if we don't want to use neither, and instead we need to do it on demand from TeamCity, or any other CI/CD tool?

I found a tool created by Microsoft which provides cli support to manage and deploy to static website.  
The tool called [Azure Static web app CLI](https://github.com/Azure/static-web-apps-cli).  
The tool provides more than deployment functionality, but has lots of features to emulate authentication, and provide proxy for the API calls from the static web site.  

But in this post we will only talk about the deployment using that tool:  

1. install the tool using npm 
```bash
npm install -g @azure/static-web-apps-cli
```

2. login using the command to login to your azure subscription and connect to existing static web app.  
If you don't have an app yet, then just ignore the `app-name` argument, and the tool will create a new app for you.

```bash
swa login --subscription-id <subscription> --resource-group <group name> --app-name <the app-name> 
```

3. navigate to the folder that has the production static files, for example let's assume our deployment files are in folder `dist`.  

4. if you want to deploy to a new static web app, then just do:  

```bash
swa deploy ./dist
```
This will ask you about the name of the new app, and will create it.  

In case you want to deploy to an existing static web app, then first you need to get that application token by doing this

```bash
az staticwebapp secrets list --name <the name of your app> --query "properties"
```

This will display a json as follows: 

```json
{
  "apiKey": "cf........700f62213"
}
```
the apikey is the token.  
Then run the following:  

```bash
swa deploy ./dist --deployment-token <the token> 
```

You will get confirmation as follows:

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hed8d7d1jx07or4vj80r.jpg)


This will not deploy to production, but to a preview environment.  
So the URL will be the same URL of your static web app, but tailed with "preview".  

This feature will give you a chance to check your app, before going to production.  
To deploy to production you add `--env production` to the previous command , so it will be

```sh
swa deploy ./dist --deployment-token <token> --env production
```
