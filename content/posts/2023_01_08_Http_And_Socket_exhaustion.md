+++
title = "Calling HTTP API and Socket Exhaustion problem"
date = 2023-01-08T12:41:54-06:00
short = true
toc = true
tags = ["asp.net"]
categories = []
series = []
comment = true
+++

You definitely had to write code to communicate to an API service. Regardless of the language you use, or the framework you use, there is a two major problems when you want to do lots of calls. They are:   
* Socket Exhaustion
* DNS Rotation

I am going to use C# and ASP.NET as an example and show you what .NET world has a solution for that, but there are solutions in every language and framework.  

## Calling an API end point.
Let us start from beginning, how to call an API service.  
```csharp
using (HttpClient client = new HttpClient())
{
     client.BaseAddress = new Uri("<baseAddress>");
     var response = await client.GetAsync("<api endpoint>");
     response.EnsureSuccessStatusCode();
     var result = await response.Content.ReadAsStringAsync();
}
```  

Let's explain what we are doing:  
1. wrap the HttpClient in `using` statement, so it disposed at the end of the block.
2. set the base address.
3. make a call.
4. Throw an exception of the request is not successful.
5. extract the result.

## How Http communication work?
Let's explore the underlying protocol that implement the HTTP call.  
When a computer needs to send a request to HTTP server, it creates a connection between the computer itself and the server.  
To open a connection the computer needs to open a port with a random number between 0 and 65,535 and connects to the server's IP address and port. 

![Image that show how sockets works](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/kjcrahe1bjf76ry4nrqx.jpg)


The combination of the computer IP address and port is called **`Socket`**.  
The problem with above code is even you dispose the Http client, but the underlying connection won't be disposed immediately, and the port won't be release right away.  
In Http protocol, when a connection disposed, it will stays in **`TIME_WAIT`** status for 240 seconds (4 minutes). To read more about the `TIME_WAIT` [check TCP/HTTP specification](https://www.rfc-editor.org/rfc/rfc9293.html#section-3.3.2).  

With lots of calls you might use all the ports on the client computer, which lead to the application will hang waiting for a port to be released.  
That situation is called **`Socket Exhaustion`**.  

## Fixing Socket Exhaustion
So what if we introduce one instance of Http Client (that is using only one random port), and keep it alive, and re-use it for all calls?  
This will solve the problem of `Socket Exhaustion`, but we introduce another problem.  
When we call an API endpoint which has the address: `https://www.myapiservice.com/api/myendpint`, the HttpClient will first call the `DNS` servers to translate "myapiservice.com" to an IP address.  

![Image shows how DNS get called](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/91ryv637vw4oqc38ooj0.jpg)

HttpClient will keep the connection open to that IP address.  
But what the IP changed in the DNS server?  
If that API was hosted in on-promise company computer then this might not happen a lot.  
But on the cloud, IP address are not that stable (unless you specifically configure it to be like that).  
By default cloud, and Kubernetes deals with the outside world with domain names, and they have their private DNS to resolve the IP resolving. Again the administrators could be using reserved IP address, but by default they are not. 
Any scale up on cloud PaaS, or even new deployment might change the IP.  
Having one HttpClient, will keep the old IP address that was detected on the first call.  

## How .NET core fixed the problem?
.NET fixed the problem by introducing a feature called **`IHttpClientFactory`** in Core version 2.1. 

 
### How IHttpClientFactory solved the problem?  
HttpClient internally is creating a connection and doing the calls using a class in .NET called **`SocketsHttpHandler`**.  
The real work of establishing a connection is happening inside `SocketsHttpHandler` , and the disposing of this handler which is taking **`Time_WAIT`** for 4 minutes to be really released.  

HttpClientFactory uses an internal class called `HttpClientHandler`, and it is the same as `SocketsHttpHandler`, which might be confusing, so before we talk what HttpClientFactory is doing, let us explain the difference.  

#### HttpClientHandler vs. SocketsHttpHandler:
HttpClientHandler was the old handler that HttpClient uses to do the real http communication. After version Core 2.1, the SocketsHttpHandler was introduced, and HttpClient started using the new handler, but HttpClientFactory kept using the old handler HttpClientHandler.  
But in Core 5.0, HttpClientHandler [was changed to use SocketsHttpHandler internally](https://github.com/dotnet/runtime/blob/f518b2e533ba9c5ed9c1dce3651a77e9a1807b8b/src/libraries/System.Net.Http/src/System/Net/Http/HttpClientHandler.cs#L16). So in reality they are the same, and when you are talking about Core version 5.0 and later both are the same which is SocketsHttpHandler.  

If you read about IHttpClientFactory you will read that it is using an internal class called HttpClientHandler, and that might create confusion.  

So back to our question how HttpClientFactory fixed the problems?  
`IHttpClientFactory` will create an internal pool of  `HttpClientHandler` and keep them and passing them when create `HttpClient`. So when create or dispose `HttpClient`, `IHttpClientFactory` is using `HttpClientHandler` from its pool.  
`IHttpClientFactory` rotate between the `HttpClientHandler` in the pool every 2 minutes (the half time of **`WAIT_TIME`**).  
For 2 minutes `IHttpClientFactory` uses one `HttpClientHandler` to create all `HttpClient` during that 2 minutes.  
And after 2 minutes, it switch to another handler, and dispose the previous handler and recreate it and add it back to the pool.  
A new `HttpClientHandler` will create new connections, which means new `DNS` calls, and getting it latest IP addresses.  
This technique solves both the problems of `Socket Exhaustion` and `DNS rotation`.   
Here a diagram from Microsoft to explain the relations between all components:  
![HttpClientFactory](/img/client-application-code.png)


## How to use IHttpClientFactory:

In ASP.NET Core, you need to add `IHttpClientFactory` as a singleton in configuring services:  

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddHttpClient()
}
```

And then you can use it to create HttpClient:  

```csharp
[ApiController]
public class MyController : ControllerBase
{
    private readonly IHttpClientFactory _factory;
    public MyController (IHttpClientFactory factory) 
    {
        _factory = factory;
    }
    [HttpGet("getdata")]
    public async Task<string> GetData()
    {
        var client = _factory.CreateClient();
        client.BaseAddress = new uri("https://www.myapiservices.com");
        var response = await client.GetAsync("<end point>");
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadAsStringAsync();
    }
}
```

## Dealing with different Http client configurations
What if you want to use different Http Client configurations with different services, and to re-use those configurations?  
ASP.NET gives two options to re-use the same configurations:  

* Named Http Client
* Typed Http Client

### Named HttpClient
You to configure Named Http Client, where you can store custom configuration
In ConfigureServices part:   

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddHttpClient("mycustomClient", (HttpClient client) => 
    { 
         client.BaseAddress = new Uri("https://www.myapiservices.com");
         client.DefaultRequestHeaders.Add( HeaderNames.UserAgent, "mycustomagent");
    })
    .ConfigureHttpClient((HttpClient client) => { ...custom configuration ...})
    .ConfigureHttpClient(
       (IServiceProvider provider, HttpClient client) => {});
}
```

How to use that?

```csharp

[ApiController]
public class MyController : ControllerBase
{
    private readonly IHttpClientFactory _factory;
    public MyController (IHttpClientFactory factory) 
    {
        _factory = factory;
    }
    [HttpGet("getdata")]
    public async Task<string> GetData()
    {
        var client = _factory.CreateClient("mycustomClient");
        var response = await client.GetAsync("<end point>");
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadAsStringAsync();
    }
}

```

#### Typed Http Client
Another way is to use Typed Http Client, which are classed that inject Http Client as follows:   

First create a class that inject HttpClient and configure it
```csharp
public class MyFinancialClient : IMyFinancialClient
{
   private readonly HttpClient _client;
   public MyFinancialClient(HttpClient client)
   {
       _client = client;
       _client.BaseAddress = new Uri("https://myapiservices.com");
   }
   public async Task<string> GetFinancialData() 
   {
       var response = await _client.GetAsync("financialEndPoint");
       response.EnsureSuccessStatusCode();
       return await response.Content.ReadAsString();
   }
}
```

And you register the class 
```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddHttpClient<MyFinancialClient>();
}

```

And then use it

```csharp
[ApiController]
public class MyController : ControllerBase
{
    private readonly MyFinancialClient _client;
    public MyController (MyFinancialClient factory) 
    {
        _client = client;
    }
    [HttpGet("getdata")]
    public async Task<string> GetData()
    {
        return await client.GetFinancialData();
    }
}
```

## Another solution using SocketsHttpHandler?  