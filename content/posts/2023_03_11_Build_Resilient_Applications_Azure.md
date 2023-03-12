---
title: build resilient applications accessing Azure services with no code.
date: 2023-03-11T21:44:55-07:00
tags: ["azure", "asp.net"]
---

When working on distributed system like systems that are running on the cloud, and microservices, then you should anticipate transient faults like temporary loss of network connection, or temporary unavailability of a service, or a service is busy.  
This is why in cloud application, the term **Building for resiliency** become a pattern in building application, and it means properly handling these transient faults in the code.  

There are two common used patterns that we can use in our code, that can help build resilience application.  
1. Retry pattern.
2. Circuit-breaker Pattern.

The good news is there are libraries that will help you doing that, and even the SDKs for some Azure services have these two patterns built-in, and by just configure the connection properly you will get this benefits without writing your own code for those.  


## Retry Pattern
The retry pattern means if calling a service failed, you wait for a short time, and then retry again because you expect the problem will be resolved shortly. You try not only one time, but maybe for 3 times, and leave a short waiting time between the retries.  

#### Services that support retry.
1. Azure SQL Server, and Entity Framework:
Entity Framework has a built-in retry technique when it comes to communicate with Azure SQL Server.
```csharp
services.AddDbContextPool<ConcertDataContext>(options => options.UseSqlServer(sqlDatabaseConnectionString,
    sqlServerOptionsAction: sqlOptions =>
    {
        sqlOptions.EnableRetryOnFailure(
          maxRetryCount: 5,
          maxRetryDelay: TimeSpan.FromSeconds(3),
          errorNumbersToAdd: null);
    }));
```
2. Azure Cache for Redis
If you are using the most famous Redis .NET library which is **`StackExchange.Redis`**, then the library has the mechanism for retry as follows:  
```csharp

var options = new ConfigurationOptions
{
    EndPoints = {"localhost"},
    ConnectRetry = 3,
    ReconnectRetryPolicy = new ExponentialRetry(
TimeSpan.FromSeconds(5).TotalMilliseconds
, TimeSpan.FromSeconds(20).TotalMilliseconds),
    ConnectTimeout = 2000
};
ConnectionMultiplexer redis = ConnectionMultiplexer.Connect(options, writer); 
```
3. Azure Service Bus
The .NET package for the service bus **`Azure.Messaging.ServiceBus`** has built-in support for retry using the configuration of its client.
```csharp

var options = new ServiceBusClientOptions();
options.RetryOptions = new ServiceBusRetryOptions
{
    Delay = TimeSpan.FromSeconds(10),
    MaxDelay = TimeSpan.FromSeconds(30),
    Mode = ServiceBusRetryMode.Exponential,
    MaxRetries = 3,
};
await using var client = new ServiceBusClient(connectionString, options);
```

#### More Azure service support retry
I am not going to list the code for all services, but just check the SDK for each service, and you will find how to enable the retry features. But these services will support the feature: 

1. Azure Cosmos DB
2. Azure Active Directory
3. Azure Search
4. Event Hub
5. IoT Hub
6. Azure Storage

#### Retry using Polly
If you need to connect to other API services, or you need to connect to Azure SQL but without Entity Framework, then you need to implement the code yourself.  
But there is a .NET package that is already doing that: [**`Polly`**](https://github.com/App-vNext/Polly).  
Let us see for example how to connect to SQL using ADO.NET and Polly:

```csharp
public async static Task<SqlDataReader> ExecuteReaderWithRetryAsync(this SqlCommand command)
{
    GuardConnectionIsNotNull(command);

    var policy = Policy.Handle<Exception>().WaitAndRetryAsync(
        retryCount: 3, // Retry 3 times
        sleepDurationProvider: attempt => TimeSpan.FromMilliseconds(200 * Math.Pow(2, attempt - 1)), // Exponential backoff based on an initial 200 ms delay.
        onRetry: (exception, attempt) =>
        {
            // Capture some information for logging/telemetry.
            logger.LogWarn($"ExecuteReaderWithRetryAsync: Retry {attempt} due to {exception}.");
        });

    // Retry the following call according to the policy.
    await policy.ExecuteAsync<SqlDataReader>(async token =>
    {
        // This code is executed within the Policy

        if (conn.State != System.Data.ConnectionState.Open) await conn.OpenAsync(token);
        return await command.ExecuteReaderAsync(System.Data.CommandBehavior.Default, token);

    }, cancellationToken);
}
```

## Circuit-breaker Pattern
There is a problem with the retry pattern. What if a service was down and stayed down for long time?  
Then every time we call this service, we are going to call it three times and wait for a second between these calls.  
This will add delay for our application.  
The Circuit-breaker pattern will fix this, by assuming the service is down after many failed calls.  
If the service marked as down, then code will immediately fail the call without even calling the service.  
This state is called `Open Circuit`.  
Then the code will wait for a while before it try again to call the service, and if it is still failing, then the state will still be `Open', otherwise it is marked as healthy, and the state will be `Closed Circuit`.  
Circuit breaker should be used in conjunction with the retry pattern.  

#### Using Cicruit-breaker with Polly.
There is built-in implementation of circuit-breaker in SDKs of Azure services, but we can achieve it using Polly package, as follows:  

```csharp
private static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy()
{
    return HttpPolicyExtensions
        .HandleTransientHttpError()
        .CircuitBreakerAsync(5, TimeSpan.FromSeconds(30));
}
```

