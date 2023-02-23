---
title: Check performance bottleneck with Azure Application Insight.
date: 2023-02-22T21:44:55-07:00
tags: ["azure", "performance"]
---


If you have Application Insight enabled for your azure app service, then it is a piece of cake to get the performance bottleneck in your app, and even it check external dependencies like database queries or any other external dependencies.  
<!--more-->
I have a Web API application, that is accessing Azure Sql Server, and Azure blob storage.  

By going into the performance blade under `Investigate` category:  
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/0mr3srn55zc4vebhm1ik.png)

You will see the average time for each API call, sorted descending by time:
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ir4wnbet13t5m4875maz.png)

By clicking on any one, you can drill down to where the time consume even by its external dependencies:

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/s693bun98iqxz1y459q8.png)

As you can see it shows the time it takes to connect to its external resources, and in our case they are:  
* Sql Server
* Blob Storage

You can even drill down to its collected samples:  
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/6vujzbb9n233osykkvkg.png)

And you can get a very granular look at the time consume in the whole workflow of that API call:

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/omzo4cgmwcncj9shn6q1.png)








[Azure Status](https://azure.status.microsoft/) is a page reports on service problems that affect a broad set of Azure customers.  

Resource Health shows all the times that your resources have been unavailable because of Azure service problems. This data makes it easy for you to see if an SLA was violated.  

Resource Health relies on signals from different Azure services to assess whether a resource is healthy. If a resource is unhealthy, Resource Health analyzes additional information to determine the source of the problem. It also reports on actions that Microsoft is taking to fix the problem and identifies things that you can do to address it.  

Health status
The health of a resource is displayed as one of the following statuses.

Available
Available means that there are no events detected that affect the health of the resource. In cases where the resource recovered from unplanned downtime during the last 24 hours, you'll see a "Recently resolved" notification.



