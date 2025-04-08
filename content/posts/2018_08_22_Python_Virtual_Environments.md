+++
title = "Python Virtual Environments & Package Management"
date = 2018-08-22T18:41:54-06:00
short = true
toc = true
draft = false
tags = ["python"]
categories = []
series = []
comment = true
+++

Python virtual environments, and as well package management, has a shaky history, and it has been changing a lot for last few years.
Even currently, (early 2018), it is confusing because there are many tools for virtual environments (venv, virtualenv, pyvenv, pyenv).
I couldn’t find one tutorial that describe everything in just one place, so I thought, I will write it down.
This post is a combination of many official documentation, answers of StackOverflow, and different blog posts that I think will give you comprehensive picture, not only for the virtual environment, but for the package management as well.


# Introduction
I’ve been doing Python on and off, and every time I came back to Python after a long time off, I had to learn again, what is the best virtual environment tool, and as well their package management.
So, I thought I will put this tutorial, that gives a comprehensive description of the Python working environment.
I will start the post with the practical side, by describing the virtual environment tools, and differences between them, and then I will go to deeper description of pip and pip ancestor, and the background of virtual environments.

### Pip Installation Folder:

To compare Pip, we can think of Node's `NPM` which store the packages in folder called `node_modules` and has only two possible locations:  

* project-level node_modules folder, which is the default option.
* user-level (global) node_modules folder.


Python’s pip will install the packages in a `site-packages` folder, which can be one of two levels:

* Machine level shared folder.
* User level shared folder, which is the default.

But to create isolatoin for each project, Python introduce tools and protocols to install in `virtual environments`.  

Python’s packaging tools provided two other pip-based tools that will do installation in two other levels:

* Virtual environment level shared folder.
* Project level installation folder.

# Installation type and scenarios:

We will list here the different case of these folders and their scenarios:

### User Level Shared Folder:
Without activating a virtual environment, Pip by default will install the downloaded packages either on a folder that belong to the user folder.
Installation on a user folder became the default, and you can control it by this command line:
```bash
python setup.py install --user
```

This is called user scheme installation mode.
The folder is located:

| OS | Folder |
| --- | --- |
| Linux	| ~/.local/lib/python{version: x.y}/site-packages |
| Mac | ~/Library/Python/{version: x.y}/lib/python/site-packages |
| Windows | %APPDATA%\Python{version: x.y}\site-packages |

You can check if this mode is enabled by this command line
```bash
python -m site 
```

The command will display the environment variable `ENABLE_USER_SITE` value, which by default is true.

### Machine Level Shared Folder

f the environment variable `ENABLE_USER_SITE` is false, then the installation will be stored on the machine folder:

| OS | Folder |
| --- | --- |
| Linux	| /usr/local/lib/python{version: x.y}/site-packages |
| Mac | /usr/local/lib/python{version: x.y}/site-packages |
| Windows | c:\Python{version: x.y}\Lib\site-packages |

### Virtual Environment Shared Folder
We can create an isolated virtual environment that can be shared between many users, where running pip install, will install inside that virtual environment without polluting the user level or machine level. To create a virtual environment, we use another tool called `virtualenv`, which can be installed with pip itself.
```bash
pip3 install virtualenv
```
Then on a directory where you want to create the virtual environment, run the following command:
```bash
virtualenv my_virtualenv
```
The above command will create a folder in the current directory which contain the Python executable files, and a copy of pip library, which will be used to install other packages.
To begin using the virtual environment, you need to activated using
```bash
source my_virtualenv/bin/activate

# Or alternative 
. my_virtualenv/bin/activate
```

The left prompt will be changed to add the name of the virtual environment.
Now, any pip install, will install the packages inside the virtual environment folder.

To deactivate the virtual environment run this command:  

```bash
deactivate
```

### Project level installation folder
Similar to NPM, Python packaging tools has a tool called `Pipenv`.
As virtualenv, you need to install pipenv separately.

```bash
pip install --user pipenv
```

Then you can start using pipenv instead of pip

```bash
pipenv install requests
```


Pipenv will install the package inside site_packages folder inside the current folder, and will create a Pipfile in the current folder (similar to package.json).  

To run the application that is using the current installation folder, you need to run python through pipenv itself.

```bash
pipenv run python your-program.py
```