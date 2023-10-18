+++
title = "Write Asp.NET webhook handlers for Azure Event Grid events."
date = 2023-10-17T12:41:54-06:00
short = true
toc = true
tags = ["asp.net"]
categories = []
series = []
comment = true
+++

Azure Event Grid is a Pub Sub message distribution service that is fully integrated with Azure infrastructure. Almost all Azure services, and PaaS, and many third-party SaaS provides integration with Event Grid, by publishing events. It is supporting Http protocol for publishing events to it, and now with a newer upgrade it supports MQTT protocol for lighter fast IoT communications.  

It is providing Pub/Sub services from Azure services to the subscribers, and adding to that reliability to insure the delivery of the messages.

## How it works:  
The following image shows how Event Grid connects sources of events with their handlers. The list is not a comprehensive list of supported publishers.

![Event Grid](https://learn.microsoft.com/en-us/training/wwl-azure/azure-event-grid/media/functional-model.png)

## What are Events?
Each Event Grid publisher, like Azure Blob Account or Azure Resource Group, will publish `events` that describe what is happening. For example: upload a blob file, or adding new resources in a resource group.  
These events are `JSON` format that will be posted using HTTP binding (or MQTT) to the Event Grid service.  
Although every publisher will have custom fields for the data that is published to the service, but they all share common fields.  
For example this is the message from a blob creation event:  

```json
{
  "topic": "/subscriptions/2fd2....fe/resourceGroups/testresourcegroup/providers/Microsoft.Storage/storageAccounts/mystorageaccount",
  "subject": "/blobServices/default/containers/x-container/blobs/rootfolder/sub-folder/file.xml",
  "eventType": "Microsoft.Storage.BlobCreated",
  "id": "43a7663a-d01e-007d-64e5-0124de044428",
  "data": {
    "api": "PutBlob",
    "clientRequestId": "8ad0d9eb-184a-4ba7-9fee-ddgg69a3d012",
    "requestId": "43a7663a-d01e-007d-64e5-0124sse00000",
    "eTag": "0x8DBC444CF804FEB1",
    "contentType": "text/xml",
    "contentLength": 1695,
    "blobType": "BlockBlob",
    "url": "https://mystorageaccount.blob.core.windows.net/x-container/rootfolder/sub-folder/file.xml",
    "sequencer": "0000000000000000000000000000D1D7000000000013cc96",
    "storageDiagnostics": {
      "batchId": "c4b15ec9-c006-0013-00e5-0171f1000000"
    }
  },
  "dataVersion": "",
  "metadataVersion": "1",
  "eventTime": "2023-10-18T17:09:20.2852276Z"
}
```
These fields are common on all messages regardless of the publisher: 

* Topic
* Subject
* EventType
* Id
* EventTime

Azure has a schema that represent those event, as well Azure supports a common de-facto industry standard schema called [Cloud Event](https://cloudevents.io) so we can use it with other cloud providers.   

## Webhook Event Delivery with Asp.NET:

Event Grid can publish messages using `Webhook` to integrate with customer's services.  
Event Grid will publish to webhook using HTTP's **`POST`** message call, submitting a `JSON` representation of the event.

The webhook handler can be any `POST` handler, and the only requirement is to add handler for a process called **`Handshake`**.  
The handshake process will start upon registering the webhook handler in Azure. The handshake process send a verification code, and there are different options to reply to this handshake request. I am going to describe the simplest way to reply to that process synchronously.  

At the time of registering the service in Azure, Event Grid will post a subscription validation event to the target endpoint.  
The `POST` call will add a header value:  
```http
aeg-event-type: SubscriptionValidation
```
and has a **`validationCode`** as follows:

```json
[
  {
    "id": "2d1781af-3a4c-4d7c-bd0c-e34b19da4e66",
    "topic": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "subject": "",
    "data": {
      "validationCode": "512d38b6-c7b8-40c8-89fe-f46f9e9622b6",
      "validationUrl": "https://rp-eastus2.eventgrid.azure.net:553/eventsubscriptions/myeventsub/validate?id=0000000000-0000-0000-0000-00000000000000&t=2022-10-28T04:23:35.1981776Z&apiVersion=2018-05-01-preview&token=1A1A1A1A"
    },
    "eventType": "Microsoft.EventGrid.SubscriptionValidationEvent",
    "eventTime": "2022-10-28T04:23:35.1981776Z",
    "metadataVersion": "1",
    "dataVersion": "1"
  }
]
```
The simplest way to validate and prove endpoint ownership is to respond back with the validation code, so this code will do that: 

```csharp
[HttpPost, Route("respondToEvent")]
public async Task<IActionResult> RespondToEvent(JArray  eventData)
{
    var azureHeader = httpContextAccessor.HttpContext.Request.Headers["aeg-event-type"];
    if (azureHeader == "SubscriptionValidation")
    {
        var validationResult = await HandleValidation(eventData);
        return validationResult;
    }
    if (azureHeader == "Notification")
    {
       await handleEvent(eventData);
    }
}
  

private async Task<JsonResult> HandleValidation(JArray  eventData)
    {
        var exp = JsonConvert.DeserializeObject<AzureEvent>(eventData[0]);
        // Do the validation
        return new JsonResult(new
        {
            validationResponse = exp.Data.ValidationCode
        });
    }

```
That was the simplest way to respond to the validation handshake.  
