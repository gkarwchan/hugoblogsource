---
title: Prepare .NET core Microservice to be monitored by Kubernetes
date: 2022-12-27T19:47:05-07:00
tags: ["kubernetes-k8s", "asp.net", "aks" ]
---

## Kubernetes Monitoring:

Kubernetes monitors the deployed microservices and check if any failure or a deadlock that makes the service not responding in order to restart the hosting container.  
Kubernetes achieve this by calling three different probes that determine the status of the container/pod. The three probes are:  
1. **liveness**: which monitor any deadlock, or the service is down, and Kubernetes will remove the dead container and restart another one.
2. **startup**: Your service might need time at startup to wait for all its dependencies to be ready. Your service will implement this probe to tell Kubernetes that your service is ready or not to receive calls.
3. **readiness**: Will tell if your service is ready or not. it is different from liveness that Kubernetes won't restart a new container, but just remove it from the load balancer.  

We create on our microservices three end points that correspond to the three Kubernetes probes, and define it in the deployment config file.  
As an example:  

```yaml
apiVersion: v1
kind: Pod
 ....
spec:
  containers:
  - name: myservice
    livenessProbe:
      httpGet:
        path: /live
        initialDelaySeconds: 5
        periodSeconds: 5
    readinessProbe:
      httpGet:
        path: /ready
    startupProbe:
      httpGet:
        path: /started
```

We don't have to implement all three and just implement what is useful for our case.  
> P.S: Because `startup` and `readiness` overlap about checking external dependencies, most systems just implement one of them.

## ASP.NET Core health check features:
ASP.NET offers health checks middleware and libraries for reporting the health of the app, and we don't have to build that from scratch.  
Let us jump to the code and write a health check for liveness, which only check if the service respond to the url "live".

```csharp
builder.Services.AddHealthChecks()
       .AddCheck("self", () => HealthCheckResult.Healthy());
var app = builder.Build();
app.UseHealthChecks("/live", new HealthCheckOptions
    {
       Predicate = r => r.Name.Contains("self")
    });
```

The above code will respond to the URL: `live` and return a string "Healthy".  

Our service is using Sql Server, so let us write a health check for readiness by checking if the sql server is available.  
Because Sql server is very common dependency in DOT.NET world, so you will expect lots of developers had to write that health check. So the community came up with many common used checks and added them in a nuget package.  

#### Common occurring health check.
Most microservices are using some kind of data store, and maybe queue messaging software.  
Checking these dependencies are part of the health check. The ASP.NET community came up with a library of predefined checks on common used resources, like for example:  
* SQL Server
* RabbitQ
* AWS S3
....  
Checkout the library [AspNetCore.Diagnostics.HealthChecks](https://github.com/Xabaril/AspNetCore.Diagnostics.HealthChecks#health-checks) to check all built-in predefined checks.  

As an example, to check the database connection as part of the healtcheck by using the above library we can write:

```cs
builder.Services.AddHealthChecks()
.AddSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
```

If you didn't find your dependency in that library then just search on github and for sure you will find someone who already did that.  

So let assume our application is using sql server and redis , and let us write our readiness check by checking them both:

```csharp
builder.Services.AddHealthChecks()
       .AddCheck("self", () => HealthCheckResult.Healthy())
.AddSqlServer(builder.Configuration.GetConnectionString("DefaultConnection",
              tags: new[] {"dependencies"})
.AddRedis("redis",
              tags: new[] {"dependencies"});
var app = builder.Build();
app.UseHealthChecks("/live", new HealthCheckOptions
    {
       Predicate = r => r.Name.Contains("self")
    });
 app.UseHealthChecks("/ready", new HealthCheckOptions
 {
    Predicate = r => r.Tags.Contains("dependencies")
 });
```

The above code will create two health check, on is the basic default one, and associate it with the url "live", and the second will check sql server and redis and associate it with the url "ready".  

And now your service is ready to be deployed to Kubernetes.
