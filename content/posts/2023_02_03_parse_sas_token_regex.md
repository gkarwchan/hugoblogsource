---
title: Parse Azure SAS token using regular expression
date: 2023-02-03T20:40:37-07:00
tags: ["azure", "security"]
---

If you have an Azure SAS token that is not working, it is good idea to parse it and understand what permissions and values it contains.  

This is a JavaScript code that uses Regular Expression to parse he SAS token, and an running example where you can try your own SAS token.

```js
var paramNames = {
  sig: 'cryptographic signature',
  st: 'start time',
  se: 'end time',
  spr: 'protocol',
  srt: 'resource types',
  sv: 'version',
  sp: 'permissions',
  ss: 'services'
};

let valueLookups = {
  sp : {
     r: 'read', d: 'delete', w: 'write', l: 'list', a: 'add',
    c: 'create', u: 'update', p: 'process', f: 'filter'
    },
  srt: {
    s: 'service', c: 'container', o: 'object'
  },
  ss : {
    b: 'blob', f: 'file', q: 'queue', t: 'table'
  }
}

let valueConvertor = (key, inputValue) => 
      valueLookups[key] ? [...inputValue].map(x => valueLookups[key][x] || x)
        : inputValue;

function parseData(sasToken) {
  let regExpressionPattern = /[?&]([a-z]*)=([^\&]*)/g;
  var parameters = [...sasToken.matchAll(regExpressionPattern)];
const finalObject = parameters.reduce((acc, row) => {
  return {...acc, [paramNames[row[1]] || row[1]]: valueConvertor(row[1], row[2])}
}, {});

  
var outputObject = ParseData(inputSasToken);

// The output object will be in the format
{
  "version":"2021-06-08",
  "services":["blob","file","queue","table"],
  "resource types":["service","container","object"],
  "permissions":["read","write","delete","list","add","create","update","process","i","y","t","filter","x"],
  "end time":"2023-02-04T03:03:37Z",
  "start time":"2023-02-03T19:03:37Z",
  "protocol":"https",
  "cryptographic signature":"..jhh"
}

```
Try it for yourself:  
  



<p class="codepen" data-height="300" data-default-tab="html,result" data-slug-hash="yLqZXNq" data-user="gkarwchan" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/gkarwchan/pen/yLqZXNq">
  Untitled</a> by Ghassan Karwchan (<a href="https://codepen.io/gkarwchan">@gkarwchan</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>