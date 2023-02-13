---
title: Some thoughts about ASP.NET Minimal API and Minimal Hosting Model
date: 2022-12-19T19:15:28-07:00
tags: ["asp.net"]
---

## Why this post?  
Looking at the new ASP.NET 6 and its minimal hosting model, triggered some thoughts comparing it to ASP.NET 2, and made me think if Microsoft going back to some old concepts. And was questioning the real benefits of migrating to this model.
So let me explain, and compare it with ASP.NET version 5 and 2.

## The new **WebApplication** builder and some history of ASP.NET:  

Let us generate a new webapi application in .net 6 using webapi template:

```bash
dotnet new webapi -n tutorial.webapi
```
You will see that we only have one file **`program.cs`**, and there is no more **`startup.cs`** and the code as follows:

Looking at the new **WebApplication** builder, I couldn't help compare it to the old ASP.NET 2 **WebHost** Builder.

If you look at old code of ASP.NET 2, which looked as follow

```csharp
var host = WebHost.CreateDefaulBuilder();
```
Which was creating **IWebHostBuilder** that will build **IWebHost**.

WebHost was not recommended after 3.x, because ASP.NET 3.x came with the idea of a generic host where you can build services that can be hosted not only on the web, but as well on Worker Services, and even Windows Services.

Another question came up was the missing of startup.cs file.

ASP.NET from version 2 (or maybe 1), distinguished between host initialization, and the web application initialization,
And to manage the two in loose coupling they created the `program.cs` file to manage the host, and `startup.cs` to initialize the web application. Where host initialization deals with reading settings from config files, environment and command line arguments, plus handle the logging, and the web initialization deals with configure ASP.NET dependency injection framework and configure the web pipeline, and they couple them with this.

```csharp
// code of program.cs
public static void Main(string[] args)
{
    CreateHostBuilder(args).Build().Run(); // 
}

public static IHostBuilder CreateHostBuilder(string[] args)
{
    return Host.CreateDefaultBuilder(args)
         .ConfigureWebHostDefaults(webbuilder => { webBuilder.UseStartup<Startup>(); });

}
```
As you can see, they achieved initialization the web application from the general host using an extension method on the IWebHostBuilder that initialize the web application in the `startup.cs` code.

The code in `startup.cs` will initialize the web by configure ASP.NET dependency injection, and define the web pipeline, and define the mappings.

So, the new WebApplication Builder, and the missing `startup` file made me ask if Microsoft is getting rid of the general host and going back to the only Webhost.

Well, the answer is NO, but before answer how, let me add the another issue I found in the new code, which is regarding the mapping URL to actions.

If we build a new minimal API project with the new template that comes with .NET 6, which is **Web template**, as follows:

```bash
dotnet new web -n tutorial.web
```
then we see the new code doesn't have any controllers, and the program.cs file doesn't have any controller mapping configurations and only has one simple mapping for GET method, and the whole code look as follows:
```csharp
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello World!");

app.Run();
```
Again going back in history to ASP.NET 2 and the mapping was configured using template mapping, which is still used in ASP.NET 5 in Razor and MVC application, and the mapping looked like
```csharp
app.UseMvc(routes => 
{
   routes.MapRoute(
    name: "default",
    template: "{controller=Home}/{action=Index}/{id?}"
   );
});
```

But with WebAPI of ASP.NET 3.x and later 5, they converted the mapping to be attribute based mapping, and you just create a controller with **[ApiController]** attribute, and add the mapping using **Route** attribute as follows:

```csharp
[ApiController]
[Route("product")]
public class ProductController: ControllerBase
{

[HttpGet, Route("")]
public Proucts[] GetProducts()
{
}
```
And all what you need is in the startup.cs file add the following to the web pipeline (configure method)

```csharp
app.UseRouting();
app.UseEndpoints(endpoints => { endpoints.MapControllers(); });
```
Again, this new style of mapping made me think if Microsoft is going back to the old mapping.

But the answer is this new mapping is a total new style of mapping and it is the heart of **the minimal API** idea.

## Minimal API
With minimal API, there is no controllers and no mapping and routing. You define the mapping for each action yourself similar to Node.js without **Express** framework.

The idea is for micro services, you don't need the whole MVC and controllers framework, and in case you need them you can bring them to your project.  
It is actually very similar to pure Node.js approach, and [if you check how to chose the port you use to run the web application](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/minimal-apis?view=aspnetcore-6.0), you will see lots of similarity with how Node works

## Minimal Hosting Model
Back to minimal hosting model which was created using the code

```csharp
var host = WebHost.CreateDefaulBuilder();
```
Was this a reverse action from the General host?

The answer is No. The WebHost builder is just a wrapper around IHostBuilder (the general host builder), and encapsulate the code that create the General Host and hook it up with the web host. So the WebHost.CreateDefaultBuilder is actually doing something similar to the following:

```csharp
var hostBuilder = Host.CreateDefaultBuilder(args)
    .ConfigureServices(services => 
    {
        services.AddRazorPages();
    })
    .ConfigureWebHostDefaults(webBuilder =>
    {
        webBuilder.Configure((ctx, app) => 
        {

            app.UseStaticFiles();
            app.UseRouting();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapController();
                endpoints.MapRazorPages();
            });
        });
    }); 

hostBuilder.Build().Run();
```
So minimal hosting model is just hide boilerplate code into the WebHost builder.

## But wait, where is the security?

If you look at the code generated for minimal hosting model, you will notice the missing authorization/authentication statements that are added on `WebApi` project, and missing https.  
In the code generated by webapi project we see this code:

```csharp
    app.UseHttpsRedirection();
    app.UseAuthentication();
    app.UseAuthorization();
```
The reason for that is in microservice/docker architecture, the authentication will be handled from the orchestrator / manager of the microservices, and all communications to the microservices are done in their own private network on HTTP and not HTTPS.

## Do you need to migrate to the new Minimal Hosting Model?  

After I read [in this section](https://learn.microsoft.com/en-us/aspnet/core/migration/50-to-60?view=aspnetcore-6.0&tabs=visual-studio#new-hosting-model) the benefits of the new model, I didn't find a real urge to merge to it, and I found it more code style rather than real performance benefits. And [I am not alone in that](https://stackoverflow.com/questions/71895364/why-migrate-to-the-asp-net-core-6-minimal-hosting-model).

Adding to that, if you read this [FAQ](https://learn.microsoft.com/en-us/aspnet/core/migration/50-to-60?view=aspnetcore-6.0&tabs=visual-studio#faq), you will see that the generic host still underpins the new hosting model and is still the primary way to host applications.

So if you are migrating from ASP.NET 6, don't bother to migrate to the new hosting model, because it is just hide and encapsulate some code that you are already written.

One important clarification that Minimal Hosting model is different than Minimal API. Minimal API doesn't include the mapping of controllers and MVC, while Minimum hosting model is still a WebAPI that built on top of MVC, but having less code than ASP.NET 5. So it is mostly hide lots of boilerplate code.

