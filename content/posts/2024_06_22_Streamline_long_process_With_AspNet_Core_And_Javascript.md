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
 public async IAsyncEnumerable<MyObject> ProcessLongData(string input)
 {
  

  for (var i = 0; i < 10; i++)
  {
   await Task.Delay(1000);
   yield return new MyObject { TextData = $"{input}-{i}", IntData = i };
  }
 }

 public class MyObject
 {
  public string TextData { get; set; }
  public int IntData {get; set;}
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
      let objAsString = new TextDecoder().decode(value);
      let obj = JSON.parse(objAsString);
    }
  }
```
