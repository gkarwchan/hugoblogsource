+++
title = "Build emails with attachments using SMTP, MIME standard (AWS SES Case)"
date = 2016-12-08T12:41:54-06:00
short = true
toc = true
tags = ["asp.net"]
categories = []
series = []
comment = true
+++

To send an email with AWS SES service, there are two options:
* Connecting directly to the AWS SMTP server with SMTP protocols.
* Or call AWS API over HTTPS.  

The SMTP is easier, but then you have to open SMTP ports (587 or 25 usually).

## Using AWS SES API:
AWS SES API has two options to send emails as described in the documentation:

* Send simple text only formatted email.
* Send email with attachments as **raw** formatted email.  

If you are sending text-only email, then your life is easy, and the API is simple straight forward.  
But sending email with attachments is not going to be straightforward, and I am going to describe the process here.  

> PS: If you just want a code that works, you can just skip to the end of the article and get the code at the end of this article. But I am trying here to describe the details of the solution, and give deeper understanding of the email protocols.

## What is an email message: SMTP?
As the following diagram shows, the client sends email messages to an email serves using SMTP protocols over port 587, and email servers communicate with the same SMTP protocol over port 25.

![SMTP Protocol](/img/SMTP-ports-1.png)

An email message that is transferred from end to end consists of three parts:

1. Envelope: The envelope contains the actual routing information that is communicated between the email client and the mail server during the SMTP session. It is constructed by the SMTP protocol, and it is analogous to the information on a postal envelope.
2. Header: Contains metadata of the message, examples are the sender’s address, the recipient’s address, the subject, and the date.
3. Body: Contains the text message.


### Message format: 
SMTP covers only the envelope part, and the rest of the message is covered by another protocol the **`Internet Message Format`** (RFC 5322).  
**`Internet Message Format`** defines the format of the Header and the Body that consists the message.


#### Simple message format:
This is an example a simple message:

```
From: "Andrew" <andrew@example.com>
To: "Bob" <bob@example.com>
Date: Fri, 17 Dec 2010 14:26:21 -0800
Subject: Hello
Message-ID: <61967230-7A45-4A9D-BEC9-87CBCF2211C9@example.com>
Accept-Language: en-US
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hello, I hope you are having a good day.

-Andrew
```
From the previous example we can extract the following:

* The header and body are separated by a blank line.
* The header consists of multi lines, each line represent a header field with its value separated by a colon.


## Using MIME
The SMTP protocol was designed to send data composed of 7-bit ASCII characters. And `Internet Message Format` was design with that restriction in mind. But email spread out and there was requirements to send more complicated data format as attachments or Unicode characters, and the industry came up with a new protocol called **`Multipurpose Internet Mail Extensions (MIME)`**.  
MIME still send data as 7-bit ASCII, but it encode the non-ASCII data to do that, and the most used encoding is base64 encoding.
The MIME standard works by breaking the message body into multiple parts and then specifying what is to be done with each part.


### Email with an attachment:  
Let’s see an example of an attachment:

```
From: "Bob" <bob@example.com>
To: "Andrew" <andrew@example.com>
Date: Wed, 2 Mar 2011 11:39:34 -0800
Subject: Customer service contact info
Message-ID: <97DCB304-C529-4779-BEBC-FC8357FCC4D2@example.com>
Accept-Language: en-US
Content-Language: en-US
Content-Type: multipart/mixed;
  boundary="_003_97DCB304C5294779BEBCFC8357FCC4D2"
MIME-Version: 1.0

--_003_97DCB304C5294779BEBCFC8357FCC4D2
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi Andrew.  Here are the customer service names and telephone numbers I promised you. 

See attached.

-Bob

--_003_97DCB304C5294779BEBCFC8357FCC4D2
Content-Type: text/plain; name="cust-serv.txt"
Content-Description: cust-serv.txt
Content-Disposition: attachment; filename="cust-serv.txt"; size=1180;
  creation-date="Wed, 02 Mar 2011 11:39:39 GMT";
  modification-date="Wed, 02 Mar 2011 11:39:39 GMT"
Content-Transfer-Encoding: base64

TWFyeSBEYXZpcyAtICgzMjEpIDU1NS03NDY1DQpDYXJsIFRob21hcyAtICgzMjEpIDU1NS01MjM1
DQpTYW0gRmFycmlzIC0gKDMyMSkgNTU1LTIxMzQ=

--_003_97DCB304C5294779BEBCFC8357FCC4D2

```

We should notice the following:

* A blank line still separate the body from the header.
* The content type is `mulitpart/mixed`.
* A `boundary` parameter specifies where each part begin and ends.
* The `Content-Disposition` header field specifies how the client should handle the attachment.
* The `Content-Transfer-Encoding` is base64, and this is the standard way that the Mime types are stored in 7-bit Ascii based text, because the SMTP still transfer the message as 7-bit Ascii.

### Email with embedded image: 
Let’s see how an email with an embedded image is represented:

```
From: Bob <bob@example.com>
To: <john@example.com>
Subject: The deal you want.
Content-Type: multipart/related;
	boundary="--boundary_1_16494d19-57aa-4462-a4c8-c8e5abefb2aa";
	type="text/html"

----boundary_1_16494d19-57aa-4462-a4c8-c8e5abefb2aa
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html>
<head></head>
<body>
<img src="cid:BannerId"><br>
The deal you want
</body>
</html>

----boundary_1_16494d19-57aa-4462-a4c8-c8e5abefb2aa
Content-Type: image/jpeg
Content-Transfer-Encoding: base64
Content-ID: <BannerId>


iVBORw0KGgoAAAANSUhEUgAAAykAAABXCAYAAAAAqgpGAAAAAXNSR0IArs4c6QAAAARnQU1B
.......
paVF/g8NZOLQHqTPpAAAAABJRU5ErkJggg==
----boundary_1_16494d19-57aa-4462-a4c8-c8e5abefb2aa--

```

We should notice the following:

* A blank line still separate the body from the header.
* A boundary parameter still used to separate parts.
* the content of the body must be HTML.
* The content type is `mulitpart/related` : and this type is used for compound documents, those messages in which the separate body parts are intended to work together to provide the full meaning of the message
* The image part has a header field called `Content-ID` which has value BannerId equal to an `ID` in the html document that specify where the image will be embedded, which is defined in the pattern `cid:BannerId`.
The binary of the image is represented as base64.



## Calling AWS SES API using C#:  
Let us now jump to programming, and see how we can call AWS SES API.


### The shortage of .NET framework:
.NET provides the namespace **`System.Net.Mail`** that helps interact with a SMTP server and send emails with complicated contents (attachments, embedded images, …etc). It abstracts the low level of generating these raw data of the email message.
But, when we use AWS SES API, we want to see and use these raw messages generated by .NET classes. Unfortunately, .NET doesn’t provide an easy way to generate these raw messages.
But there are three solutions:

1. We build the raw message ourselves, which is going to be a nightmare and a magnet for bugs.
2. Using un undocumented hack in .NET assemblies.
3. Using third party libraries that does generate the raw message.
Of course, I am not interested in building the raw message by myself, so let’s ignore that and describe the two other solutions:


### Using a hack in .NET Framework
There is an undocumented way to generate the raw message from Microsoft .NET assemblies, but with a small hack. The namespace `System.Net.Mail` provides internal classes and members that cannot be called directly, but can be accessed using reflection. There are these two useful entities: `System.Net.Mail.MailMessage` has an internal method called **`Send`**, which will generate the `Raw` message and write it into a stream. `System.Net.Mail.MailWriter` is an internal class that is used by the above method to write the `Raw` message. I used this approach, and I will show a sample code of it:

```cs
public void SendMessage()
{
    // Here we construct the System.Net.Mail.MailMessage 
    // using all the tools in the System.Net.Mail namespace 
    // that help us build a complicated message.
    // for examples: Attachment, LinedResource (for embedded resources)...
    System.Net.Mail.MailMessage message = ConstructMessage();

    // Here where we generate the raw message
    var rawASCII_message = ConvertMessageToAscii(message);
    
}

private string ConvertMessageToAscii(MailMessage message)
{
    Assembly assembly = typeof(SmtpClient).Assembly;
    Type mailWriterType = assembly.GetType("System.Net.Mail.MailWriter");
    MemoryStream fileStream = new MemoryStream();

    // Create an instance of the internal class MailWriter
    ConstructorInfo mailWriterContructor = mailWriterType.GetConstructor
        (BindingFlags.Instance | BindingFlags.NonPublic, null, new[] { typeof(Stream) }, null);
    object mailWriter = mailWriterContructor.Invoke(new object[] { fileStream });

    // Call the internal method "Send" of the MailMessage
    MethodInfo sendMethod = typeof(MailMessage).GetMethod("Send", 
        BindingFlags.Instance | BindingFlags.NonPublic);
    sendMethod.Invoke(message, BindingFlags.Instance 
        | BindingFlags.NonPublic, null, new[] { mailWriter, true }, null);

    // Now mailWriter has the raw data
    // Read the stream as ASCII
    var reader = new StreamReader(mailWriter, Encoding.ASCII);
    var rawMessage = reader.ReadToEnd();
    MethodInfo closeMethod = mailWriter.GetType().GetMethod
        ("Close", BindingFlags.Instance | BindingFlags.NonPublic);
    
    closeMethod.Invoke(mailWriter, BindingFlags.Instance 
        | BindingFlags.NonPublic, null, new object[] { }, null);
    return rawMessage;
}

```

### Third-party solutions
The .NET community came up with third-party libraries that help parse/generate all MIME types that are even not supported by .NET framework:

* MimeKit.
* MimeKitLite.
* SharpMimeTools
* OpenPop.NET.

and there are others.
The above libraries will generate and parse MIME based raw messages.
