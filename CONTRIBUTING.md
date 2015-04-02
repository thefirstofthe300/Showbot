# How to contribute

## Workflow

1. [Fork the repo](https://github.com/rikai/Showbot/fork),
2. Branch from `devel`,
    * `git checkout -b BRANCHTYPE/issue-or-descriptive-name devel`
    * `BRANCHTYPE` should be `FEATURE` for features, `BUG` for bugs,
    * `issue-or-descriptive-name` should be the issue number _or_ a descriptive name of what is being implemented
3. Make the change,
    * Follow code conventions,
    * Test your code to make sure it works right,
4. Make a pull request,
5. Make any requested adjustments,
6. If/When accepted, party :tada:

## What you will need

You will need the following tools to contribute to JBot:

 * [RVM with Ruby 1.9.2 or Greater](https://rvm.io/)
 * [Bundler](http://gembundler.com/)
 * Git
 * SQLite3
 * MySQL

If you are not familiar with Git, check out the [free ebook](http://git-scm.com/book/).

## Working on JBot

Working on JBot requires a working knowledge of Ruby, as that is the language
it is written in. YAML and JSON are also handy to know.

JBot is built on the [Cinch framework](https://github.com/cinchrb/cinch). Check
out the [docs for Cinch](http://www.rubydoc.info/github/cinchrb/cinch/master) to
learn how to use it.

### Setup

To get JBot up and running for development, follow the
[setup steps in README.md](https://github.com/rikai/Showbot/blob/devel/README.md#setup)
for running the development version of JBot. All development for JBot takes
place on the `devel` branch, so make sure you're on it!

### Quick Start

The quickest way to get started with JBot is to build a plugin. We have written
[QUICKSTART.md](https://github.com/rikai/Showbot/blob/devel/docs/dev/QUICKSTART.md)
in docs/ detailing how to quickly create a simple plugin for JBot.

### Important files

There are a few files that are most important when developing for JBot. Below is
and outline of what those files are and how they work.

#### cinchize.yml

The `cinchize.yml` file is the core configuration file for JBot. In it, various
settings can be set for both the core and the plugins. Plugins can also be
activated/deactivated based on whether they are specified in the file. This
means that a plugin can be turned off by simply commenting out it's name and
config data in `cinchize.yml`.

A `cinchize.yml.example` file has been added to the repo to show an example
configuration, as well as to show all the available options and plugins. As
plugins are added, example configurations are added to the example file. Some
plugins require a number of different configuration options while others require
no options at all. The easiest way to build your `cinchize.yml` file is to copy
the example file and edit it according to your particular needs.

The `cinchize.yml` file is written in [YAML](http://en.wikipedia.org/wiki/YAML).

#### data.json

This file is used by several JBot plugins. The `data.json` file contains
information about whether there is a live show, and when it is. There is no
example version of this file in the repository. Currently, this file is
generated externally, and lives in `public/`. To use it (and for the plugins
that depend on it to work correctly), you must start JBot's web server.
Alternately, you can point JBot at an externally hosted data.json file by
setting the configuration in your `.env` file.

The `data.json` file has separate [additional documentation](https://github.com/rikai/Showbot/blob/master/docs/dev/DATA.JSON.md).

#### public/shows.json

This file is closely related to the `data.json` file, and is also used
independently by several plugins. It provides a list of shows (and some data
about them) to JBot.

<!-- TODO: Document more! -->

#### .env

The `.env` file sets environment variables for JBot. The `.env.example` file is
included in the repo for exemplary purposes. The most important field that needs
set in this file is `DATA_JSON_URL`. You should point that at a URL for your
`data.json` file.

#### showbot_irc.rb and showbot_web.rb

The `showbot_irc.rb` and `showbot_web.rb` files are the bootstrappers for JBot.
They start up the IRC and web components of JBot. You **should not** need to
change `showbot_irc.rb`. If you find yourself needing to change something in
there, [open an issue](https://github.com/rikai/Showbot/issues/new) and talk to
us about it first. Otherwise, your contributions may not be accepted.

The `showbot_web.rb` file, on the other hand, contains much of the logic for the
web interface for JBot. This means that sometimes it can change. Inside of this
file, you will find that JBot's web interface is a Sinatra web application that
shares a database with the IRC bot.

#### lib/cinch/plugins/*

This directory holds all of JBot's plugins, which define JBot's core functions,
a.k.a. all the things that make JBot such a nice bot. Most development happens
in these files, and in the related `lib/models/` directory. If you are adding
something new to JBot, this is the most likely starting point.

Plugin classes must all be in the `Cinch::Plugins` module, and must include the
`Cinch::Plugin` module to work correctly. New plugins must also be added to the
`cinchize.yml` file to be loaded by JBot.

#### lib/models/*

The `lib/models/` directory contains all of the model classes used by JBot's
plugins. All models are `require`d at application start, and so are always
available to plugins. You _may_ use models from another plugin if it suits your
needs, **but** please don't mess with a model's internal global state (as
another plugin may depend on that), and please don't instantiate new instances
of models that use up resources (such as hitting an API endpoint, as those are
often limited). If you need to use such a model across multiple plugins, please
[open an issue](https://github.com/rikai/Showbot/issues/new) and talk to us
about it first.

## Code conventions

* Two spaces
* Use descriptive variable and function names
* Parens only where necessary and where they improve readability
* Name casing:
    * Classes/Modules: `class PascalCase`
    * Constants: `CAPITAL_SNAKE = 42;`
    * Functions/Methods: `def snake_case`
    * Variables, parameters, etc: `snake_case = 42`
* Spaces around operators
