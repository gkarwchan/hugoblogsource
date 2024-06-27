+++
title = "Stream long running webapi with Asp.NET Core and Javascript"
date = 2024-06-22T10:41:54-06:00
short = true
toc = true
draft = false
tags = ["asp.net", "javascript"]
categories = []
series = []
comment = true
+++

If you have a long running process that return array of data, or a data that you can send back as chunk
of data, then you can stream the result.

## Streaming from the server

In Asp.NET core 6 and later, it is so easy to stream back the result using `IAsyncEnumerable`.  
Let us jump into the code right away:  

```csharp
 [HttpGet("ProcessLongData")]
 [ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
 public async IAsyncEnumerable<string> ProcessLongData(string input)
 {
  

  for (var i = 0; i < 10; i++)
  {
   await Task.Delay(1000);
   yield return i.ToString();
  }
 }
```
#### How ASP.NET serialize the result back?
Json serializer `System.Text.Json` has a built-in support to serialize stream, so you don't have to do anything because it is the default serializer for Asp.NET core.  
But what in case your project is using `NewtonsoftJson`?  
Then you need to override the json serializer for that controller, or that method.  
You do that by using the [Action Filter](https://learn.microsoft.com/en-us/aspnet/mvc/overview/older-versions-1/controllers-and-routing/understanding-action-filters-cs) in Asp.NET.  
Here is a code that will do that:  

```csharp
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.Formatters;

public class SystemTextSerializerAttribute : ActionFilterAttribute
{
    public override void OnActionExecuted(ActionExecutedContext context)
    {
        if (context.Result is ObjectResult objectResult)
        {
            var options = new JsonSerializerOptions(JsonSerializerDefaults.Web);
            objectResult.Formatters.RemoveType<NewtonsoftJsonOutputFormatter>();
            objectResult.Formatters.Add(new SystemTextJsonOutputFormatter(options));
        }
        else
        {
            base.OnActionExecuted(context);
        }
    }
}
```



## How the browser receive the data
The browser will receive the data as chunck of data. If we inspect with chrome dev tool, we can see the following data:  
![Image Receive 1](/img/stream1.png).  

![Image Receive 2](/img/stream2.png).  

![Image Receive 3](/img/stream3.png).  



## How to handle stream in JavaScript
JavaScript has the ability to read stream using the [Stream API](https://developer.mozilla.org/en-US/docs/Web/API/Streams_API/Using_readable_streams).  

A simple code will look like: 
```js
  var postStream = async (path, body) => {
    
    let response = await fetch(path, { method: "POST", body });
    const reader = response.body?.getReader();
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      if (!value) continue;
      let textValue = new TextDecoder().decode(value);
      console.log('the received value:', textValue);
    }
  }
```
Because the result is considered as an array, the result will be as follows:

```bash
the received value: [1
the received value: ,2
the received value: ,3
...
the received value: ,9]
```

To remove the trailling brackets and commas we remove them with regex
```js
      let textValue = (new TextDecoder().decode(value)).replace(/^\[/, '').replace(/]$/, '').repace(/^,/, '');
```
#### How to report back to the caller:

We can use generator function feature to report to the caller:

```js
  var postStream = async function* (path) {
    
    let response = await fetch(path, { method: "POST", body });
    const reader = response.body?.getReader();
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      if (!value) continue;
      let textValue = (new TextDecoder().decode(value)).replace(/^\[/, '').replace(/]$/, '').repace(/^,/, '');
      yield textValue;
    }
  }
```
And from the caller:

```js
  var genFunc = await postStream("path");
  var valueObj = genFunc.next();
  while (!valueObj.done) {
    // do something with valueObj.value
    valueObj = genFunc.next();
  }
```


## Host on Azure Web App Windows
One last thing to mention.  
If you want to host your webapi application on Azure Web App (App Service) for Windows, then Azure will use IIS to host the application, and IIS has its own buffering.  
To avoid IIS buffering, you add to the controller's method the following:

```csharp
 [HttpGet("ProcessLongData")]
 [ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
 public async IAsyncEnumerable<string> ProcessLongData(string input)
 {
  
  HttpContext.Features.Get<IHttpResponseBodyFeature>()?.DisableBuffering();
  for (var i = 0; i < 10; i++)
  {
   await Task.Delay(1000);
   yield return i.ToString();
  }
 }
```