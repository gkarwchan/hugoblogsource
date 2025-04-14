+++
title = "Scrubbing Natural Language"
date = 2019-09-05T18:41:54-06:00
short = true
toc = true
draft = false
tags = ["python", "machine learning"]
categories = []
series = []
comment = true
+++

Scrubbing a natural language text data is a widely used process that has well defined steps which you will find it in many places. From Lucene which is the Full text search engine that is used in Elastic Search and Azure Search, to any data science project that is processing Natural Language, including different ML projects, and general search projects.

# Introduction

### A brief introduction to the Data Scrubbing:
I am going to cover data scrubbing in more details in comming posts, but just to briefly explain why it is an important step.  
Any data science project, or machine learning project, should start from clean data, which means data that is vallid and doesn’t corrupt the model, or the training process.  
It is the second step to do in any data science project after the first step which is Gathering the data.
This step is called `Data Scrubbing` or `Data Cleansing`.


### Cleaning Natural Language Text
Scrubbing Natural Language text data has common and well defined steps that are the same and repeated in different kind of projects, either being Full Text Search like Lucene engine, or any machine learning that is using Natural language Processing (NLP).  
In this post we are going to describe these steps, and see how we can do them using Python’s nltk library.

# Scrubbing Natural Language Text
In order to process and get useful data from a natural language text, you need to do the following:  

1. Remove numbers and punctuations.
2. Remove `Stop Words`.
3. Remove human names if neccessary.
4. Stemming and Lemmatization.

  
### 1. Remove numbers and punctuations
We don’t need nltk to do this step, because python already provides for us with a constant **`string punctuation`** which contains all punctuations, and we can remove numbers using a regular expression.  
To remove numbers we can as well use python’s isalpha which is a method on a string instance, which check if the word is only alphabetic.

#### Code
You can remove punctuations using this code:  

```python
simple_text = 'this. is. a test, for removing: punctuation words, and to show! the result? something.'
clean_text = simple_text.translate(str.maketrans('', '', string.punctuation))
```

and to remove the numbers we can use:  

```python
simple_text = 'this string has 2 numbers to 1: detect the numbers and 2 to remove them something.'
clean_text = [word for word in simple_text.split() if word.isalpha()]
print(clean_text)
```

### 2. Remove Stop Words
Stop Words are the most common used words in any language and they don’t give any value to the text context or the text specific subject. Like for example: the, a, who, what, at, which....

#### Code
**`ntlk library`** has the stop words in different languages. In order to see those words in English as an exmple, try this code:

```python
import nltk
from nltk.corpus import stopwords
set(stopwords.words('english'))
```

Let us now remove the stop words from the text:  

```python
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize

def remove_stop_words(sampleText):
  stop_words = set(stopwords.words('english'))
  word_tokens = word_tokenize(sample_text)
  filtered_words = [w for w in word_tokens if not w in stop_words]
  return filtered_words

sample_text = 'this is an example text, in order to show the stop word removal'
print(remove_stop_words(sample_text))
```

### 3. Remove human names
Unless you are doing search on human names, these human names could be a problem when trying to classify a text, or search text.

#### Code
Same as stop words, nltk has all names, which you can see using the following:

```python
from nltk.corpus import names
set(names.words())
In order to clean the text from the names, use the following code:

from nltk.corpus import names

def remove_human_names(sampleText):
  all_names = set(names.words())
  word_tokens = word_tokenize(sample_text)
  filtered_words = [w for w in word_tokens if not w in all_names]
  return filtered_words

sample_text = 'this is an example text, in order to remove names like: Michael, George, Dexter from the text'
print(remove_human_names(sample_text))
```

### 4. Stemming and Lemmatization
Stemming and Lemmatization are Text Normalization or Word Normalization techniques, to relate words with similar meanings.  
Python’s nltk has the Wordnet which is a large lexical database for English language. It offers lemmatization capabilities as well.  

#### Code

```python
import nltk
nltk.download('wordnet')
from nltk.stem import WordNetLemmatizer 
lemmatizer = WordNetLemmatizer()
sample_text = 'this is some text string include strings variables where each variable has different word and have something in common'
result = [lemmatizer.lemmatize(word.lower()) for word in sample_text.split()]
print(result)
```