---
title: Check performance bottleneck with Azure Application Insights.
date: 2023-02-22T21:44:55-07:00
tags: ["azure", "performance"]
---


If you have Application Insights enabled for your azure app service, then it is a piece of cake to get the performance bottleneck in your app, and even it check external dependencies like database queries or any other external dependencies.  

I have a Web API application, that is accessing Azure Sql Server, and Azure blob storage.  

By going into the performance blade under `Investigate`:  
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

## Wait, there is more
If the app administrator had concerns about the performance, and want to inform the developer team, then they can report the issue from Application Insights.  
On the right side, you can create a **`Work Item`** to report this issue to the dev team.  

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/kyg5duvxy0h3korp97yn.png)

You need to have a `Work Item Template`, which define where you report those issues. There are two venues where you report the issues:  
1. Azure DevOps.
2. GitHub Repository, where it report it to the `Issues` tab in the repository.  

Creating a template is easy, but I am not going to cover it here, and I am already created a template the report in my github repo.  

After you create a `Work Item`, (in my case I had already template, it will create an issue with the name of the API call

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/8wcdmrm07p6c7jjfx1bx.png)

and inside the issue will have a link to the details captured in Application Insights.

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/kejv8yf70spkg4j2ntag.png)

