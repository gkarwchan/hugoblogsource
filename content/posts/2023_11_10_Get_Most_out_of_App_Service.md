+++
title = "Get the most out of Azure App Service."
date = 2023-11-10T12:41:54-06:00
short = true
toc = true
tags = ["azure"]
categories = []
series = []
comment = true
+++

Azure App service take care of tons of infrastructure, hosting, scalability, monitoring, deployment, DevOps, security and environment of your shoulders.  

But the question, are you really utilizing the most out of this wonderful service?  
Azure App service has tons of features that make it easy to forget about some of them and missing using them.  

I am going to list this checklist and explain more details on them. There are features that **Must** be implemented, and there are features that are optional because you might be using other services to achieve their functionalities.

### Must be implemented features:

1. Scalability and auto-scaling out/in.
2. Staging deployment slots.
3. Using App Configurations and Key Vault to store sensitive data and certificates.  
4. Use virtual networking to secure other SaaS resources.
5. Use managed identity.  
6. Integrate with other Azure web services for security and performance.  

### Other Optional features:
1. Using Azure built-in authentication.
2. Logging and instrumentation.
3. API management.



# Must implement features: 

## 1. Scalability and auto-scaling
Autoscaling in Azure App Service monitors the resource metrics of a web app as it runs. It detects situations where other resources are required to handle an increasing workload, and responds to changes in the environment by adding or removing web servers and balancing the load between them. Autoscaling provides elasticity for your services. For example, you might expect increased/reduced activity for a business app during holidays.

Autoscaling improves availability and fault tolerance. It can help ensure that client requests to a service won't be denied because an instance is either not able to acknowledge the request in a timely manner, or because an overloaded instance has crashed.

As well by auto-scaling down when the demands go down, you will save money.

## 2. Use deployment slots:
When you deploy to an App Service (anything Standard and better), you can deploy to a staging environment to test your deployment, with different configuration, and after you test it you can switch it to production with zero downtime.
So what is difference between a deployment slot and separate staging environment?  
The staging environment has a different App Service Plan, and App Service, where the deployment slot is deploying to the same App Service Plan, which means it might deploy to the same worker machines that host the production ones, or machines from the same images that are defined in the App Service Plan.  
As well deployment slots provide zero production deployment because when you deploy to the deployment slot, and after you test it and you are ok with it, you `swap` the slot, which is only switch the configurations and the routing, which take zero downtime.  


## 3. Using Key Vault and App Configurations.
If you have sensitive credentials and you want to provide them for your application, it is essentials to not store these in your code repository.  Instead we can use the App Configuration and for secrets we can use Key Vault.  
[Key vault provides extra layer of security over App Configuration](https://learn.microsoft.com/en-us/azure/azure-app-configuration/faq#should-i-store-secrets-in-app-configuration).  
And more important, A user with App Service Administrator can add configuration to reference the key vault without having access to the key vault data.  So if you are using database credentials and you want to keep it secret even from the user who is managing the App Service, then you can store it in Key Vault and let the manager reference the key vault in the app configurations.  

## 4. Virtual Networking
If you are using other SaaS services on Azure, like databases or message queue, or cashing service, then you can use virtual networking to provide a secure and private connection between the App service and those services. Those services will be secured from the outside world and only accessed through a private connection to your app.  [Here and example on how to create a private connection between App service and Azure Sql Server](https://www.ghassan.page/posts/2023_01_10_azure_networking_reciep_one/).  

## 5. Managed Identity:
Managed Identity is an Microsoft Entra Identity that is issued for an application, so the application can provide this identity to other services (like database), and because it is Microsoft Entra identity so you can use it like any other identity and you don't need to store the credentials to communicate to the database.  

## 6. Integrate with other Azure web services: 
There are two services that can increase the security and enhance the performance of the web application and they are easy to integrate to App service:  
* Azure CDN (to host any media or static files). 
* Web Application Firewall (WAF), which provide a security layer of your web application to protect against multiple attacks.  

# Optional features:

## 1. Built-in Authentication / Authorization
App Service provides built-in authentication and authorization support, and it is integrated with all other Azure services that your app is using.  
Even you are using third-party authentication provider, if that provider is compliant with Federated Identity standards (SAML, OAuth, OpenID Connect), then you can still using it and integrated with the built-in features of App services, and you can sync the users from third-party authentication to Azure authentication provider and using RBAC to control authorization.
The following Identity providers are available by default:
1. Microsoft Identity Platform.
2. Facebook
3. Google
4. Twitter
5. OpenID connect provider
6. GitHub

## 2. Built-in logging and instrumentation:
## 3. API Management




