---
title: Implement a watchdog for your microservices using off-the-shelf ASP.Net Healthcheck UI.
date: 2023-02-02T20:22:20-07:00
tags: ["asp.net", "azure", "aks"]
---

## What is a watchdog
A watchdog is a service that monitor other services and take actions when it detect a service is failing.  
ASP.NET starting from Core 5 has a built in UI module to monitor other services, and in few line of code you can build a watchdog for your services.

## How to hook it up with your services:

Your microservices should implement health check endpoints to be monitored by the orchestration service (Kubernetes, docker storm, ... etc).  
[I explained in previous post](https://dev.to/gkarwchan/prepare-net-core-microservice-to-be-monitored-by-kubernetes-4pgn) on how to use built-in ASP.NET health check features to achieve build these endpoints.  
I recommend reading that article because there I talked about the Microsoft package [AspNetCore.Diagnostics.HealthChecks](https://github.com/Xabaril/AspNetCore.Diagnostics.HealthChecks). This package contains all the middleware for build-in health checks, and as well in the same repository has a UI module that with few line of code build a UI to monitor all integrated services and monitor their health check endpoints.  

## How to use the UI module to build the monitoring service.
1. Create a MVC application using 
    ```bash
        dotnet new mvc -n watchdog
    ```
2. Add required packages:
    ```bash
       dotnet add package AspNetCore.HealthChecks.UI
    ```

3. define in appsettings.json all the services that you want to monitor. the format of the config section is as follows:
    ```json
        // Configuration
       {
         "HealthChecksUI": {
            "HealthChecks": [
               {
                  "Name": "Ordering HTTP Check",
                  "Uri": "http://host.docker.internal:5102/hc"
               },
              {
                "Name": "Ordering HTTP Background Check",
                "Uri": "http://host.docker.internal:5111/hc"
              },
             //...
           ]}
          }
    ```
    In reality when we deploy the application to AKS or any service-mesh service, we need to replace the url address. But now we are just describing the idea of the UI module.

4. add HealthCheckUI service

```csharp
builder.Services..AddHealthChecksUI()
            .AddInMemoryStorage();

// ....
var app = builder.Build();
// ....

// the URL /hc-ui will display the user interface
app.UseHealthChecksUI(config => config.UIPath = "/hc-ui");

```

When you run the application you will see the user interface that looks like

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/yw32ctetod4xjx33q2l2.png)

I am going to add more on monitoring services using other built-in features, so keep following me.
