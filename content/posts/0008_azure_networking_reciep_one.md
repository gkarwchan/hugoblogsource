---
title: Azure Networking Recipes: Connect Azure Database and an Azure App Service using Virtual Network.
date: 2023-01-10T20:00:24-07:00
tags: ["azure", "azure networking", "azure app service"]
---

If your application is connecting to Azure database, or any other resources, then connecting them through Virtual Network (VNet) will enhance the performance (assuming the app service and the resources are in the same region), as well it enhance the security and we can lock the resources to have private endpoint, and not accessed publicly. 
I am going to go through a walk-through tutorial, using Azure Sql Server as an example, but this can work with any database on Azure, or even any resources like blob storage.  

## Prerequisite for this post:
This post is to describe how to define a network connection between your application deployed on the App Service, and your database server. I am assuming that you already have an App service on Azure, and created a database on Azure.  
This tutorial is using the portal, so I am assuming you have knowledge of Azure portal enough to navigate around and create resources.  

## Virtual Network connection in a nutshell:
In a nutshell when we connect an App Service to any other resource through a virtual network (VNet, later we will use the term VNet for virtual network), we should do the following:  
1. From App Service side, we make all outbound connections go through the VNet. This feature is called **`VNet integration`**.
2. From the resource side, we create a service endpoint or a private end point.  

Don't get worry that you don't understand those terms, because we are going to describe them and their functionalities in details later. But we can summarize the App service and its connection to Azure resource through VNet using this diagram.

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/6rvesohir95ocanl46tf.png)

## Walkthrough to create VNet connection:  
  

### Step 1: Create a VNet:
From Azure portal, select Resources / Virtual Network, and then create a virtual network.  
Fill in the details of virtual network name and region.  
select region the same where Azure SQL server, and the App service

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/svfyj3y357m16hvyorp7.png)

For the IP addresses just keep the default, and keep the default subnet.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/og2a869v7v9omte62icj.png)

For security keep everything disabled right now, and we might change that later.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/p429inzy1y92mxpu3y47.png)
Then continue to creation and click on create, and wait for the VNet to be created.  
  

### Step 2: Create a subnet for the App Service integration:

The next step is to create a subnet and integrate our App service in it.  


#### What is App Service VNet Integration:

To make our app service communicate to other resources on the VNet we enable App Service VNet integration.  

VNet integration is used only to make outbound calls from your app into your virtual network.
VNet integration supports connecting to a virtual network in the same region. If you want to connect to resources in other regions or VNet in other regions then we need to add a gateway, but that will be outside the discussion of this post.     

Create a subnet in the VNet and keep the addresses as default, and call it **`appSubnet`**

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/1ggf0zozol3e3hl2ayii.png)

Still in the subnet scroll down until you find **`Subnet Delagation`** and choose : 
```sh
Microsoft.web/ServerFarms
```

#### What is Subnet Delegation?
Delegation means a given subnet is only going to be used by that service, and in our case App service Plans are defined as **`Microsoft.web/serverFarms`**.  

Save and continue to next step.  

### Step 3: Enable App service integration to the new subnet:
After we created a subnet and make it dedicated to serve App Service plans, now we want to integrate our App service to that subnet.  
Go to your App Service, and select the **`Network blade`**.  
Choose VNet integration.  
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/dmpy6z8nusglo4tmbdwa.png)

Choose Add VNet
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/uurt7hsqcjdl943n5zpb.png)

Add the existing Subnet **`appSubnet`**:
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/91ih2k99ut34eewsi7if.png)

### Step 4: Create Private EndPoint for Azure SQL Server:

Private endpoint are not the only solution to connect to SQL server from a VNet, but in this post we are going to choose this path, and we might explain alternatives in a different post.  
To connect Azure Sql server to a VNet we have to create two items:
* Private endpoint
* Azure Private Link
The following diagram explain the job of each part
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/3xxyxykzfiqid356l509.png)

#### What is Private Link?

Private Link will bring services delivered on Azure into our VNet by mapping it to a private endpoint. Or privately deliver your the services in VNets. All traffic to the service can be routed through the private endpoint, so no gateways, NAT devices, ExpressRoute or VPN connections, or public IP addresses are needed. Private Link keeps traffic on the Microsoft global network.

From Azure portal create a **`Private Endpoint`**. Make the region the same where your VNet and Sql server is:
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ey8gypz8pq66aypyhqa4.png)
Move next to **Resources** and chose : **Connect to an Azure resource in my directory** and choose **`Microsoft.SqlServer`**, and then choose the server.  

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/cgva4xcfv96l1ueb0hgd.png)

Next move to virtual network and choose our VNet:  
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/5hmc70n9s0pumqsz7n0a.png)
And on next screen: DNS keep the default to integrate with private DNS

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/t8ezx2p6f6sc6p4gqwnk.png)
then create the private endpoint.  
This process will create the following:  
1. Private Endpoint
2. Private Link
3. Connect to the VNet through network interface
4. Define a private DNS for sql server name resolution, so you can keep your old connection string from the app server the same.

If you go to the VNet, you will see that it has now an endpoint.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/i7cwa9kci6ltrpduun50.png)
and if you navigate to the endpoint blade you will see the new endpoint.  

#### More about the benefits of private endpoint
One of the benefits of Private Endpoint feature is that since all connections are being sent directly to your logical Azure SQL Server via the private IP address, they no longer need to flow through the Azure SQL Database gateways. In the public endpoint flow, connections are first sent to one of the Azure SQL gateways to then get redirected back to the node hosting the database.

By using Private Endpoint, the Azure SQL Database gateways are bypassed completely and always use port 1433. This reduces your security risk footprint by ensuring communication to your database is never going through the Azure SQL gateway and is locked to one address on a single port and from your Virtual Network. If you aren't familiar with the Azure SQL Database connectivity architecture, there's a great Microsoft Docs article on it.
Just like anything, there are benefits, limitations, and trade-offs to every feature. Here are some things to keep in mind when using Private Endpoints with Azure SQL Database:

Private Link is one way only. This allows clients on your VNet to connect to the Azure SQL resource but doesn't allow Azure services to reach into your Virtual Network. This makes sense when dealing with databases but remember that Private Link is a networking feature for many Azure services, not just Azure SQL Database. 
The Azure Private Endpoint is at the logical SQL Server level. So, you have access to everything on that server via the private IP address, not to only a single database. This could be both good or bad, depending on your needs. 
When removing the public endpoint, make sure to also think about turning off the Allow Azure Services option, so it also blocks anything else running in an Azure data center from getting in.


