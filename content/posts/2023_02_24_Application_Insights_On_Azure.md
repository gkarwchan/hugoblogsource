---
title: Everything you need to know about telemetry for your Asp.NET application on Azure.
date: 2023-02-24T21:44:55-07:00
tags: ["azure", "asp.net"]
---
Azure provides services for instrumentation and observability (monitoring) of applications, and all these services reside under Azure Monitor.  

Azure Monitor is an umbrella of three services:  
1. Azure Monitor itself which provides the observability part to monitor your applications.
2. Application Insights, or its alternative OpenTelemetry which provides the telemetry, and instrumentation part.
3. Log Analytics which provides the analytics part.  

In this post we will focus on the instrumentation part.

## Telemetry and instrumentation in Azure.
Telemetry, the data collected to observe your application, can be broken into three types or "pillars":  
* Distributed Tracing
* Metrics
* Logs
Azure provides two services that cover this area:  
* Application Insights
* OpenTelemtry
Application Insights in the service that provides comprehensive and rich tools to collect data about your application, and it is the service that we are going to cover it in this post. But it is worth talking briefly about `OpenTelemetry`.  

### OpenTelemetry on Azure:
OpenTelemetry is the new kid in the hood and it is the future of telemetry.It is an initiative trying to standardize and unify telemetry APIs and SDKs, and build vendor-neutral SDKs for telemetry.  
It is still in early phase of development, and it only cover the **Distributed Tracing** part of the telemetry. 
This technologies are used a lot in docker and Kubernetes world.  
Azure Monitor recently start to adopt OpenTelmetry by reading its data. But generally speaking until the technology move more steps forward, and specially if we are working on App service, and Azure functions we should chose Application Insights because it has way more features.  

Now back to Application Insights.  

## Application Insights and Auto-Instrumentation:
You can enable Application Insights on an App Service or Azure Function without writing any line of code.
This feature is called Auto-instrumentation or “Run-time instrumentation”
This feature is available because the App Service base image has a built-in agent that will collect the instrumentation and communicate with the Application Insights server.

Asp.net core (on both linux and windows) supports Auto-instrumentation.

To enable Auto-instrumentation on an App Service, on Azure Portal check the App Service, and on the left side there is **`Application Insigths`** blade.  
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/eflexlh7m9gd41lkpwv1.png)
Then you enable it on the App Service.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/opsn6eio4ylbu2w9pxfd.png)

#### Auto-instrumentation on client side:
If you are using Asp.NET MVC application on Windows hosted App Service, or using Azure Static Web App, you can auto-instrument your JavaScript code, by just doing the following:  
Add a new application setting **`APPINSIGHTS_JAVASCRIPT_ENABLED`** and set its value to **`true`**.  
That will inject JavaScript SDK for Application Insights in your JavaScript code.  
 
Client-side instrumentation captures information about the user experience of the app, including page load times, details of browser exceptions, and performance data about AJAX calls. 

## Application Insights and Manual-Instrumentation:
Although Auto-instremenation will provide good coverage, it is not enough.
We need to track our application manually from inside the code.
The more we track from inside the code the more coverage we will have on the performance and operational issues we encounter in production, which translates to better support.

#### Manual instrumentation on the Asp.NET server code:  
To collect telemetry from the code, we need to include NuGet package:  
```
Microsoft.ApplicationInsights.AspNetCore
```
Then initialize the service from the code:  

```csharp
var builder = WebApplication.CreateBuilder(args);

// The following line enables Application Insights telemetry collection.
builder.Services.AddApplicationInsightsTelemetry();
```

You can pass the connection string in the code, but better to provide it from the `appsettings.json` file as follows:

```json
// in appsettings.json
"ApplicationInsights": {
    "ConnectionString": "Copy connection string from Application Insights Resource Overview"
  }
```

By just adding these few lines, our SDK will collect lots of metrics from the running application. It will collect:  

* Application Dependencies: for example communication with databases including sql statements, or with blob storage.
* Performance Counters: for example memory and CPU usage.
* Events Counter: There are built-in events that the SDK will collect, and you can create your own custom event. For a list of built-in events [check this link](https://learn.microsoft.com/en-us/azure/azure-monitor/app/eventcounters).

