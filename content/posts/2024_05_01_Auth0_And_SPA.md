+++
title = "Auth0 Single Sign On and seamless silent authentication"
date = 2024-05-01T10:41:54-06:00
short = true
toc = true
draft = false
tags = ["security"]
categories = []
series = []
comment = true
+++

Auth0 streamlines lots of complexity for you when it comes to authenticate your SPA application.  
In this article we will talk about how Single Sign ON works.

## Auth0 Single Sign On and sessions:

Auth0 provides Single Sign-on through the use of sessions. There are up to three different sessions:  
1. Local session.
2. Authorication Server session, if SSO is enabled.
3. Identity Provider (IdP) session, if the user login through an IdP like Google, Facebook...etc.

## How SSO works:

1. the application will redirect the user to login page on Auth0 Authorization Server.
2. Auth0 checks to see if there is an existing SSO cookie for the authorization server.
3. there is no cookie, so the user will be redirect to the login page.
4. after login, Auth0 will set SSO cookie and redirect the user to our application, returning the ID token.
5. The user compes back to our application.
6. the application will redirect to the login page.
7. Auh0 check for SSO cookie.
8. Auth0 will find the cookie and update it without the login process.

The developer can check for the SSO session from their application by using Auth0 SDK: [Auth0.js](https://auth0.com/docs/libraries/auth0js).



So, there is a redirect to the login page all the time, but in `Authorization Code Flow with PKCE` workflow in conjuction with `Silent Authentication` can renew your session without relogin, and redirect.


## Silent authentication

To get a fresh token with silent authentication, all you have to do is using Auth0 SDK: [Auth0.js](https://auth0.com/docs/libraries/auth0js), you call `checkSession` or `getTokenSilently` on older versions, and the library will do the magic for you.  
So what that magic is, and how that works?

#### How silent authentication work?

Auth0 used to use cookies to store the Auth0 session to be able to get back the authentication.  
But modern browsers prevent third-party cookies, therefore Auth0 shifted to use : **`Refresh Token Rotation`**, which provides a secure way for using refresh tokens in SPA while providing end-users with seamless access to resources without the disruption in UX.  

The library using iframe will call the `authorization server` (`AS`) for an endpoint that will try to authenticate silently.  

`OpenId Connect` protocol supports a `prompt=none` parameter on the authentication request, which indicate the Authentication Server (`AS`) must not display any user interaction. The Auth0 server will either return a successful token or return an error, in which case the user has to redirect to login.  

to authenticate using OpenId Connect use the following endpoint:  

```http
GET https://{yourDomain}/authorize
    ?response_type=id_token token&
    client_id=...&
    redirect_uri=...&
    state=...&
    scope=openid...&
    nonce=...&
    audience=...&
    response_mode=...&
    prompt=none
```

Because the library use iframe targetting `AS`then it can check the stored cookies for that server.  
The above call will either return success, or failure.  
The failure has `ERROR_CODE` that describe the failure.  

The possible values for ERROR_CODE are defined by the OpenID Connect specification:

1. login_required: The user was not logged in at Auth0, so silent authentication is not possible. 
2. consent_required: The user was logged in at Auth0, but needs to give consent to authorize the application.
3. interaction_required: The user was logged in at Auth0 and has authorized the application, but needs to be redirected elsewhere before authentication can be completed; for example, when using a redirect rule.

The library silently will refersh the token for you using [Refresh Token Rotation](https://auth0.com/docs/secure/tokens/refresh-tokens/refresh-token-rotation)