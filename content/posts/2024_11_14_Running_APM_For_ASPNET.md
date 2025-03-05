+++
title = "Enable APM for ASP.NET Core application"
date = 2024-11-14T18:41:54-06:00
short = true
toc = true
draft = false
tags = ["security"]
categories = []
series = []
comment = true
+++

There are many tools that provide APM (Application Performance Monitoring) for Asp.NET.  
The all share the same steps and configuration on how to hook their service into Asp.NET running instance.  


# How profiling work in .NET
Profiling a managed CLR application is different than profiling normal non-managed appication, because CLR is different. CLR prvides these services:  
* Application domains
* Garbage collection
* Managed exception handling
* Just In Time (JIT) compilation

.NET provides its own profiling API, and all profiling tools are using this API, and they all work in the same way.  
When a managed application starts, it loads the CLR, and when the CLR initialized, it looks for these two environment variables:  

* CORECLR_ENABLE_PROFILING
* CORECLR_PROFILER
The `CORECLR_ENABLE_PROFILING` should be 1, and the `CORECLR_PROFILER` is a GUID that unique for a specific APM provider.  
If profiling is enabled, CLR will look for the profiling library and load it. The profiling library will be provided by another environment variable, or variables:  

| Env. Variable Name | Description |
| --- | --- |
| CORECLR_PROFILER_PATH | the path to the dll file |
| CORECLR_PROFILER_PATH_32 | the path to the dll file 32 bit |
| CORECLR_PROFILER_PATH_64 | the path to the dll file 64 bit |


# Hosting your application on Azure

If you are hosting your application on Azure, then we will list the above environment variable values:  

## Using Azure Application Insight:

You can use Azure Application Insight which will provide an easy way to configure the application.  
From Azure or from Bicep, you can attach Application Insight to your app, and everything will be configured automatically.  


| Env. Variable Name | Value |
| --- | --- |
| CORECLR_PROFILER_PATH | D:\Home\site\wwwroot\<the path for the dll> |

Example **`NewRelic`**:

| Env. Variable Name | Value |
| --- | --- |
| CORECLR_PROFILER_PATH_32 | D:\Home\site\wwwroot\newrelic\x86\NewRelic.Profiler.dll |
| CORECLR_PROFILER_PATH_64 | D:\Home\site\wwwroot\newrelic\NewRelic.Profiler.dll |
| CORECLR_NEWRELIC_HOME | D:\Home\site\wwwroot\newrelic |


