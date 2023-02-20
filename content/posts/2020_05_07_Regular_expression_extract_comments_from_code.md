---
layout: post
title: 'Regular expression: Extract Comments From Code'
date: '2020-05-07T09:45:00'
author: Ghassan Karwchan
tags:
- algorithm
---


Explain advanced concepts of Regular Expressions through practical receipes:  
In this recipe we are going to cover:

* Capturing Group
* Negated Character Class
* Greedy / non-greedy quantifier.

<!--more-->

## Problem Description

We need to parse a file of code to extract the comments in the code.  
The comments can be single line comments:

```JavaScript
// this is a single line comment
x = 1; // a single line comment after code
```
Or multi lines

```JavaScript
/* This is one way of writing comments */ 
/* This is a multiline 
   comment. These can often
   be useful*/
```
<br />
<br />

## Code

The final code in JavaScript:

```javascript

function processData(inputText) {
    var t = String.raw`(//[^\n]*|/\*[\s\S]*?\*/)`
    var ex = new RegExp(t, 'g')
    var ar = inputText.match(ex).map(x => 
        x.split('\n').map(y => y.trimStart()).join('\n')
        )
    return ar
} 
```

And Python

```python
import sys
import re

def extract_comments(txt):
    comments = [ j.lstrip() for i in re.findall(r'(//[^\n]*|/\*.*?\*/)', 
        txt, re.MULTILINE | re.DOTALL) for j in i.split('\n')]
    return '\n'.join(comments)
```

<br />
<br />

## Code Description

Let us explain the code.  
  
For Python:  


1. we start by writing the pattern in a string and prefix it with **`r`** prefix, which treat the rest as `Raw` string, which means ignore the escape character **`\`** and treat it as normal character.
    ```python
    r'the pattern string'
    ```
2. Because we want to extract the comments in the code, so we have to create `Capturing Group`. The capture group will capture the text matched by them into a numbered group. We create a capture group with **`()`**.
    ```python
    r'(the pattern of comments to match)'
    ```
3. We have two styles of comments to capture: single line comment, and multi-lines comment. this is why we separate them with **`|`**. so our regular expression format is:
    ```python
    r'(single line format | multi-line format)'
    ```
4. The first comment style is single line comment, which starts with **`//`**.  
5. and then we should match all the rest of characters until new line. To do that we use **`Negated Character Class`** : `[^\n]*` which means any character but new line. Negated Character Class will match any character that is not in the negated character class.  
    ```python
    r'(//[^\n]*| multi-line format)'
    ```
6. We are done with first style of comments, and let us move to the second style of comments which is multi-line.  
7. the multi-line comment starts with **`/*`**. We represent that with `/\*`. Notice how we added the escape character `\ ` before the star, so we treat the star as a normal star and not a special character.  
8. Then we need to match any character including new line, and to do that we use the special character (Dot) **`.`**. The special character **`.`** (Dot) will match any character except the new line, but in Python there is an option we can specify to makes the Dot matches new line, and that option will be passed to match statement `re.DOTALL`.
    ```python
    re.findall(r'(pattern with Dot)', txt, re.MULTILINE | re.DOTALL)
    ```
9. to close the multi-line comment we add the following to the pattern: `\*/`, which make the whole pattern as follows:  
    ```python
    re.findall(r'(//[^\n]*|/\*.*\*/)', txt, re.MULTILINE | re.DOTALL)
    ```
10. Now there is a problem with previous code, which is caused by `Greedy quantifier`. We will discuss this in details later, but now to continue and finish, to fix the problem we add `?` after the star `*` to be as follows: 
    ```python
    re.findall(r'(//[^\n]*|/\*.*?\*/)', txt, re.MULTILINE | re.DOTALL)
    ```

Before we jump to greedy quantifier, let us discuss JavaScript code.  

#### JavaScript Code

The JavaScript code is very similar to the python except one important exception. JavaScript doesn't have an option to force the special character `.` (Dot) to match new line as in Python, and the alternative is to match this:
    ```javascript
    [\s\S]*?
    ```
And for an alternative for `re.MULTILINE` in python there is a flag `g` in JavaScript.
    ```javascript
    var t = String.raw`(//[^\n]*|/\*[\s\S]*?\*/)`
    var ex = new RegExp(t, 'g')
    ```

<br />
<br />

## Greedy and non-greedy quantifier:
An Example on extracting comments that are not working:  

For the input text:

```javascript
/* Iterate through the list till we encounter the last node.*/
    while(pointer->next!=NULL)
    {
            pointer = pointer -> next;
    }
    /* Allocate memory for the new node and put data in it.*/
```

It will generate this output
```javascript
/* Iterate through the list till we encounter the last node.*/
    while(pointer->next!=NULL)
    {
            pointer = pointer -> next;
    }
    /* Allocate memory for the new node and put data in it.*/
```

To fix this problem we will add `*?` as non-greedy quantifier.

```python
re.findall(r'(//[^\n]*|/\*.*?\*/)', txt, re.MULTILINE | re.DOTALL)
```

To explain more:  
By default, a quantifier tells the engine to match as many instances of its quantified token or sub-pattern as possible. This behavior is called greedy.  
As an example to match 

```javascript
var rg = /.*apple/g
var input = 'a tasty apple'
input.match(rg)
```

The previous code won't match because the `.*` is greedy, so it swallow all characters, and then nothing left for `apple`.
The default behavior when you try to match something with the quantifier, it matches the longest possible.   

<br />
<br />

## Regular Expression Series:

This article is part of a series about regular expression. These are the other articles:  

1. [Advanced Regular Expression By Example : An Introduction]({% post_url 2020-05-06-Advanced-regular-expression-by-examples %})
1. Extract Comments from code ( this article)
3. [Extract Domain Name]({% post_url 2020-05-08-Regular-expression-extract-domain-names %})
4. [Extract Links From HTML Document]({% post_url 2020-09-11-Regular-expression-extract-html-links %})