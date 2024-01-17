+++
title = "Using Azure Managed Identity to skip sharing credentials"
date = 2024-01-14T10:41:54-06:00
short = true
toc = true
tags = ["azure", "security"]
categories = []
series = []
comment = true
draft = true
+++

A common challenge for developers is the management of secrets and credentials used to secure communication between different components making up a solution. Managed identities eliminate the need for developers to manage credentials.  
While developers can securely store the secrets in Azure Key Vault, services need a way to access Azure Key Vault. Managed identities provide an automatically managed identity in Microsoft Entra ID for applications to use when connecting to Azure resources. Applications can use managed identities to obtain Microsoft Entra tokens without having to manage any credentials.


## How does Managed Identity work:
Internally, Managed Identity is a special type `Service Principal`, which is locked to be used by only Azure resources, and there are two types of Managed Identity in Azure:  
1. System-assigned managed identity: which is an identity related to a specific Azure service, like Azure App Service, or Azure Virtual Machine. 
2. User-assigned managed identity: which is a stand alone dedicated identity that we created separately.

The difference between the two can be sum up as follows:  

* System-assigned can be used only by the Azure service that the identity was created on. So an identity created for App Service can work only with that App Service. On opposite, a user-assigned can be used by any Azure service.
* The life of a system-assigned is associated with its associated service, so if we delete the service, the identity will be deleted. Where for user-assigned its lifecycle depends on our decision.  

When we create a managed identity, either system-assigned or user-assigned, then Azure will create a `Service Principal` in Microsoft Entra default tenant that is associated with the subscription.   
For system-assigned one, Azure will assign that `Service Principal` as the identity for associated Azure service.  

After creating the identity you use Azure RBAC to give that identity the permissions of target Azure resources (like database for example).

## An example: Web app that access Sql Server

Let us create an example of a web application hosted on an App Service, that connect to an SQL server.  

#### 1. create the service plan

{{< tabs >}}
{{% tab name="python" %}}
```python
print("Hello World!")
```
{{% /tab %}}
{{% tab name="R" %}}
```R
> print("Hello World!")
```
{{% /tab %}}
{{% tab name="Bash" %}}
```Bash
echo "Hello World!"
```
{{% /tab %}}
{{< /tabs >}}