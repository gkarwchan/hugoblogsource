+++
title = "A Journey into Microsoft Identity Platform"
date = 2024-08-19T10:41:54-06:00
short = true
toc = true
draft = false
tags = ["azure", "security"]
categories = []
series = []
comment = true
+++

It is not exaggeration if I said, Microsoft Identity Platform is bigger than any SAS authentication provider, and if you are using Azure as your cloud provider, then the authorization benefits that will add to your application off-the-shelf, won't be able to do it with any other platform without writing code.

# Usage with .NET

.NET has a library, which is considered part of the platform. It is `Microsfot.Identity.Web`.  
 
### How to use it?

```csharp
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.UI;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddAuthentication(OpenIdConnectDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApp(builder.Configuration.GetSection("AzureAd"));

builder.Services.AddControllersWithViews(options =>
{
    var policy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .Build();
    options.Filters.Add(new AuthorizeFilter(policy));
});
builder.Services.AddRazorPages()
    .AddMicrosoftIdentityUI();

var app = builder.Build();
```

### Explaining the code
The library `Microsoft.Idenity.Web` provides lots of workflow behind the scene, and it is the latest.
More about the library later.
What the code will do for your application:

1. Downloading the Microsoft Entra ID metadata, finding the signing keys, and finding the issuer name for the tenant.
2. Processing OpenID Connect sign-in workflow and obtaining JWT token, extracting the user's claims, and putting them in `ClaimsPrincipla.Current`.
3. Integrating with the session cookie Asp.NET core middleware to establish a session for the user.
4. Build an authorization policy, where views require authentication. Every controller has the attribute `[Authorize]` will force the user to validate its authentication token.
5. Add UI that will be hooked to Microsoft authentication URL: https://login.microsoftonline.com/

# Configure Microsoft Entra ID:
To configure Microsoft Entra ID to authenticate your application, you have to register your application.  
Application Registration in Microsoft Entra ID is equivalent to create an Application in Auth0.  

### Configure your .NET to use Microsoft Entra ID application:
To configure the application use the following in appsettings:



```json
{
  "AzureAd": {
    "Instance": "https://login.microsoftonline.com/",
    "TenantId": "common",
    "ClientId": "11111111-1111-1111-11111111111111111",
    "CallbackPath": "/signin-oidc"
  },
}
```
Where:

* Instance: is the login url where Microsoft Entra ID (single tenant or login with School or work).
* client ID: is the client ID for your App Registeration (will come to it later)
* TenatantId: cloud be one of the following:
    * a real Id for tenant, for single tenant application
    * **organizations** for multi-tenants applications that use Work/School accounts.
    * **common** for work/school accounts or MS personal accounts.
    * **consumers** Microsoft personal accounts

