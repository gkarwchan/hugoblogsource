---
title: No More JavaScript Transpiler
date: 2020-12-23T16:02:54-07:00
tags: ["javascript"]
---

With modern browsers supporting ES6 modules, and Edge is adopting Chromium which align the major browsers to use latest EcmaScript features, we don't need to use transpilers like Webpack or Gulp.  
This will make it easier on many areas, and enhance the performance of our applications.  

<!--more-->

### Using JS modules in the browser

On the web, you can tell browsers to treat a \<script\> element as a module by setting the type attribute to module.

```html
<script type="module" src="main.mjs"></script>
<script nomodule src="fallback.js"></script>
```

Browsers that understand type="module" ignore scripts with a nomodule attribute. This means you can serve a module-based payload to module-supporting browsers while providing a fallback to other browsers.  
The ability to make this distinction is amazing, because if the browser can understand module, then it understand all the new features of JS like arrow functions or async-await.  Which means for module script, you don’t have to transpile those features in your module bundle anymore! You can serve smaller and largely untranspiled module-based payloads to modern browsers. Only legacy browsers get the nomodule payload.

Modules are deferred by default, but classic \<script\> blocks the HTML parser by default. You can work around it by adding the defer attribute, which ensures that the script download happens in parallel with HTML parsing.


Module scripts are deferred by default. As such, there is no need to add defer to your \<script type="module"\> tags! Not only does the download for the main module happen in parallel with HTML parsing, the same goes for all the dependency modules!

```html
<script type="module" src="main.mjs"></script>
<script nomodule defer src="fallback.js"></script>
```
