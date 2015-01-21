# How to contribute

## Workflow

1. [Fork the repo](https://github.com/rikai/Showbot/fork),
2. Branch from the branch `branch-from-here`,
    * `git checkout -b BRANCHTYPE/issue-or-descriptive-name branch-from-here`
    * `BRANCHTYPE` should be `FEATURE` for features, `BUG` for bugs,
    * `issue-or-descriptive-name` should be the issue number _or_ a descriptive name of what is being implemented
3. Make the change,
    * Follow code conventions,
    * Test your code to make sure it works right,
4. Make a pull request (bonus points for topic branches),
5. Make any requested adjustments,
6. If/When accepted, party :tada:

## What you will need

You will need the following tools to contribute to JBot (package names are for Ubuntu):

* Ruby 2.0+
* Rake
* Bundler
* Git
* Other packages:
    * libmysqlclient-dev
    * sqlite3
    * libsqlite3-dev
    * libxml2-dev
    * libxslt1-dev

If you are not familiar with Git, check out the [free ebook](http://git-scm.com/book/).

## Working on JBot

Working on JBot requires a working knowledge of Ruby, as that is the language
it is written in.

### Setup

These commands will get you setup to run Showbot.

 * `git clone https://github.com/rikai/Showbot.git`
 * `cd Showbot`
 * `bundle`
 * `foreman run rake db:migrate`

Finally you need to setup your `.env` file in the root of the project. At the
bare minimum you'll need the following:

```
# Bot lib folder
RUBYLIB=./lib

# Set this if you want to use a language other than english.
# You will also need to create a corresponding .yml file in the locales folder.
SHOWBOT_LOCALE=en

# Foreman stuff
## Production port
PORT=80
## Development port
DEVELOPMENT_PORT=5000

# Point this to the url of data.json, if you have one
SHOWBOT_DATABASE_URL=your_info_here

# For backup.rb
BOT_DATABASE_NAME=your_info_here
BOT_DATABASE_USER=your_info_here
BOT_DATABASE_PASSWORD=your_info_here
BOT_DATABASE_HOST=your_info_here
BOT_DATABASE_PORT=your_info_here
BOT_DATABASE_OPTS=your_info_here
S3_ACCESS_KEY_ID=your_info_here
S3_SECRET_ACCESS_KEY=your_info_here
S3_REIGON=your_info_here
S3_BUCKET=your_info_here
S3_PATH=your_info_here
S3_KEEP=your_info_here

# Point this to the url of data.json, if you have one
DATA_JSON_URL=your_info_here
```

### Configuring IRC

 * Customize [`cinchize.yml`](https://github.com/rikai/Showbot/blob/master/cinchize.yml) for your IRC channel.
 * Update [`fix_name`](https://github.com/rikai/Showbot/blob/master/lib/cinch/plugins/showbot_admin.rb#L54) to match your bot's name.

### Launching Showbot

**Website and the IRC Bot**

```
$ bundle exec foreman start -f Procfile.local
```

**Just the Website**

```
$ bundle exec foreman start web -f Procfile.local
```

**Just the IRC Bot**

```
$ bundle exec foreman start irc -f Procfile.local
```

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

