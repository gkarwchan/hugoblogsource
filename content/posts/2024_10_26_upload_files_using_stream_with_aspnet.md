+++
title = "Upload files using streaming in Asp.NET"
date = 2024-10-26T18:41:54-06:00
short = true
toc = true
draft = false
tags = ["asp.net"]
categories = []
series = []
comment = true
+++

Asp.NET provide a binding technique to upload files **`IFormFile`**. But that technique will consume memory as it buffers the content of the file in the memory or in the database.  
To skip buffering and use streaming, we kind of have to code it in own our way.  

## Http Protocol and uploading file:

The simplest way to upload file is to create an Html `file input` element, and include it in `html form` with `submit` button as follows:

```html
<form name="form1" method="post" enctype="multipart/form-data" action="api/upload">
    <div>
        <label for="caption">Image Caption</label>
        <input name="caption" type="text" />
    </div>
    <div>
        <label for="image1">Image File</label>
        <input name="image1" type="file" />
    </div>
    <div>
        <input type="submit" value="Submit" />
    </div>
</form>
```
We can describe the code as follows:  

1. the corner stone of uploading file is an input of type **`file`**, which the web browser will provide functionality to pick a file from local device.
2. when we upload file, we submit it as `Html Form` data, and the form should have `enctype` as **`multipart/form-data`** which is different from the usual form encoding: `application/x-www-form-urlencoded`
3. the form's action attribute point to the server side that will handle the uploading.

#### How the browser will send the data?
The browser will send the data as follows:

```http
POST http://localhost:50460/api/upload HTTP/1.1
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-us,en;q=0.5
Accept-Encoding: gzip, deflate
Content-Type: multipart/form-data; boundary=---------------------------41184676334
Content-Length: 29278

-----------------------------41184676334
Content-Disposition: form-data; name="caption"

any caption
-----------------------------41184676334
Content-Disposition: form-data; name="image1"; filename="GrandCanyon.jpg"
Content-Type: image/jpeg

(Binary data not shown)
-----------------------------41184676334--
```

The above message has two three parts:

1. the meta data that describe the http message. The important point to notice that we are defining the **`boundary`** that seperate these parts.  
2. the second part (separated by the boundary) is the normal form encoded inputs (the caption)
3. the last part is the file binary data encoded as `base64`. 

It is the browser who does all that work of encoding the http message.  

#### How to read it from the server side?
From the server side Asp.NET provide the `IFromFile` to bind to the file

```csharp
[Route("upload")]
public class UploadController : ApiController
{

[Route("")]
[HttpPost]
public async Task UploadFile([FromForm] IFormFile image1, [FromForm] string caption)
{

}
}

```

Notice in the code above that the name of the parameter **`image`** is the same name of the `input` element on HTML form.

You can access the file with its content from the interface `IFormFile`.  

#### How Asp.NET upload the file:
Asp.NET will read the content of the mssage, and it will buffer it in memory, until it reach a specific size (64KB) specified in [MemoryBufferThreshold setting](https://learn.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.http.features.formoptions.memorybufferthreshold?view=aspnetcore-8.0#microsoft-aspnetcore-http-features-formoptions-memorybufferthreshold).  
if the size is bigger than `MemoryBufferThreshold`, then the system will buffer it on the disk.

## Upload file without HTML form and submit
If you are dealing with SPA application then you cannot use the built-in browser functionality to upload the file and you have to do it on JavaScript side.  
The following code will do that part:

```javascript
async function uploadFile () {
    let uploadedFile = document.getElementById('file').files[0];
    const formData = new FormData();
    formData.append("file", uploadedFile);
    formData.append("caption", "some caption");

    try {
    const response = await fetch('api/upload', {
      method: 'POST',
      body: formData
    });

    if (response.ok) {
      window.location.href = '/';
    }

    var result = 'Result: ' + response.status + ' ' + 
      response.statusText;
    } catch (error) {
      console.error('Error:', error);
    }
  }
```


## Upload file using streaming

As we discussed before `IFormFile` will do buffering for the file data.  
What if we want to avoid that?  
To reduce memory usage you can upload the file using streaming, but there is no off-the-shelf API for that in ASP.NET, and you have to go to lower level and rebuild the whole process of reading Http message yourself.  
Let's see some code



```cs
    [HttpPost]
    [Route(nameof(Upload))]
    public async Task<IActionResult> Upload()
    {
        var request = HttpContext.Request;

        // validation of Content-Type
        // 1. first, it must be a form-data request
        // 2. a boundary should be found in the Content-Type
        if (!request.HasFormContentType ||
            !MediaTypeHeaderValue.TryParse(request.ContentType, out var mediaTypeHeader) ||
            string.IsNullOrEmpty(mediaTypeHeader.Boundary.Value))
        {
            return new UnsupportedMediaTypeResult();
        }

        var boundary = HeaderUtilities.RemoveQuotes(mediaTypeHeader.Boundary.Value).Value;
        var reader = new MultipartReader(boundary, request.Body);
        var section = await reader.ReadNextSectionAsync();

        // This sample try to get the first file from request and save it
        // Make changes according to your needs in actual use
        while (section != null)
        {
            var hasContentDispositionHeader = ContentDispositionHeaderValue.TryParse(section.ContentDisposition,
                out var contentDisposition);

            if (hasContentDispositionHeader && contentDisposition.DispositionType.Equals("form-data") &&
                !string.IsNullOrEmpty(contentDisposition.FileName.Value))
            {
                // Don't trust any file name, file extension, and file data from the request unless you trust them completely
                // Otherwise, it is very likely to cause problems such as virus uploading, disk filling, etc
                // In short, it is necessary to restrict and verify the upload
                // Here, we just use the temporary folder and a random file name

                // Get the temporary folder, and combine a random file name with it
                var fileName = Path.GetRandomFileName();
                var saveToPath = Path.Combine(Path.GetTempPath(), fileName);

                using (var targetStream = System.IO.File.Create(saveToPath))
                {
                    await section.Body.CopyToAsync(targetStream);
                }

                return Ok();
            }

            section = await reader.ReadNextSectionAsync();
        }

        // If the code runs to this location, it means that no files have been saved
        return BadRequest("No files data in the request.");
    }

```
 
