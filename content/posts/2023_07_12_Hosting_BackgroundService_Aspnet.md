+++
title = "Best way to run background services in ASP.NET."
date = 2023-07-12T12:41:54-06:00
short = true
toc = true
tags = ["asp.net"]
categories = []
series = []
comment = true
+++


Asp.Net provides many ways to run background processes. They are:  
* IHostedService interface
* BackgroundService abstract class
* Worker Service using Microsoft.NET.SDK.Worker

Actually they are just layers on top of each others, each layer provides extra functionality on the one below.  
This post is going to describe each layer and what it provides.  

## Running background tasks using `IHostedService`
Asp.NET provides support for running background tasks in the same process that host Asp.net application.  
By implementing `IHostedService` interface, your background task will start a little bit after Asp.Net application start, and end when Asp.Net application shutdown.  

> P.S.: Asp.NET core server, Kestrel itself is a hosted service.  

IHostedService has two methods:

```csharp
public interface IHostedService
{
    Task StartAsync(CancellationToken cancellationToken);
    Task StopAsync(CancellationToken cancellationToken);
}
```

After you implement the interface, you need to register the task, and register it with the DI container. Asp.NET provides `AddHostedService` extension method on `IServiceCollection` for that purpose:

```csharp

public void ConfigureServices(IServiceCollection services)
{
   services.AddHostedService<MyExampleService>();
}
```
#### Using **scoped** services in the background task:
`AddHostedService` is doing registering the service as Singleton in the DI container.  
That leads to a problem if you need to use services registered as scoped-lifetime services.  
To fix this problem, create a new container scope anywhere you need access to scoped service, as the following code:

```csharp
public class MyExampleService : IHostedService
{
   private readonly IServiceProvider _provider;
   public MyExampleService (IServiceProvider provider)
   {
      _provider = provider;
   }

   public Task StartAsync (CancellationToken cancellationToken)
   {
     using (IServiceScope scope = _provider.CreateScope())
     {
         var scopedProvider = scope.ServiceProvider;
         var client = scopeProvider.GetRequiredService<ExampleScopedService>();
         ...
      }
    }
}
```

#### Guidelines on IHostedService
There are subtleties to implementing the interface correctly. In particular, the `StartAsync` method, although asynchronous, runs inline as part of your application startup. Background tasks that are expected to run for the lifetime of your application must return a Task immediately and schedule background work on a different thread. Calling await in the `IHostedService.StartAsync` method will block your application from starting until the method completes. This can be useful in some cases, but it’s often not the desired behavior for background tasks.  


## BackgroundService
To make it easier to create background services using best-practice patterns, ASP.NET Core provides the abstract base class `BackgroundService`, which implements `IHostedService` and is designed to be used for long-running tasks. To create a background task you must override a single method of this class, `ExecuteAsync`. You’re free to use async-await inside this method, and you can keep running the method for the lifetime of your app.

## Worker Service
.NET provides a special kind of application called `Worker Service`, which runs IHostedService in a host that is lighter than Asp.NET host.  
That lighter host is `Microsoft.Extensions.Hosting.Host`, which is a general host that is hosting the Asp.Net WebApplication itself.  
[I wrote before](https://www.ghassan.page/posts/2022_12_19_aspnet_minimal_api/) about the relation between Host and WebApplication.  
The worker service's `Host` will run background service, but doesn't handle HTTP request. It has the following:  
* configuration features.
* logging features.
* dependency injection features.

To use Worker Service, run the following:   
```bash
dotnet new worker
```

This will create a **`BackgroundService`** class, that is hosted in **`Microsoft.Extensions.Hosting.Host`**, which is an implementation of **`IHost`** which what we described as a lightweight host.  

## Running Worker Service in production
You can run Worker Service as a Windows Service, or Linux's Systemd service.  
