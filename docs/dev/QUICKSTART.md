# Plugin Development Quick Start Guide

To demonstrate how to build a plugin, we're going to develop a basic echo plugin
for JBot. JBot uses the Cinch framework for its core functionality. Cinch
documentation can be [found online](http://www.rubydoc.info/github/cinchrb/cinch/master).

## Build the skeleton

To make the plugin, we start by creating `lib/cinch/plugins/echo.rb`.

```
$ touch lib/cinch/plugins/echo.rb
$ $EDITOR lib/cinch/plugins/echo.rb
```

Inside of that file goes the following content:

```ruby
module Cinch
  module Plugins
    # Plugin classes go inside of the Cinch::Plugins module
    class Echo
      # We include the Cinch::Plugin module to add all the Cinch magic
      include Cinch::Plugin
    end
  end
end
```

We've just created the most basic Cinch plugin ever. It does absolutely nothing.
To load our plugin, we now need to edit the `cinchize.yml` file.

```
$ $EDITOR cinchize.yml
```

We add our plugin under the `plugins` section:

```
---
# Plugins used for all configs
plugins: &plugins
  plugins:
  -
    class: "Cinch::Plugins::Echo"
  -
    class: ...
```

We can now start JBot, and it will load up our plugin, but it doesn't do very
much, so there's no way to tell. We need to add some behavior to our plugin to
make it more interesting.

## Adding behavior

We open up the plugin class again to add our behavior.

```
$ $EDITOR lib/cinch/plugins/echo.rb
```

Our plugin is intended to see the !echo command, and echo back whatever is after
the command. We can implement this basic behavior as follows:

```ruby
module Cinch
  module Plugins
    # Plugin classes go inside of the Cinch::Plugins module
    class Echo
      # We include the Cinch::Plugin module to add all the Cinch magic
      include Cinch::Plugin

      # The match macro allows us to match commands posted into the IRC channels
      # we are listening on. It uses a regex to match messages, and map them to
      # plugin methods to handle the commands. Capture groups can be used for
      # capturing parameters for the method. Here we are capturing everything
      # after !echo so we can echo it back. The prefix is automatically added to
      # the regex by JBot, so no need to match that.
      match /echo\s+(.*)/i, :method => :command_echo # !echo

      # The convention in JBot is to prefix methods that respond to IRC commands
      # with the command_ prefix, followed by the command name.
      #
      # The m parameter is a Cinch message. This provides information about the
      # message sent, including the user that sent it, the channel it was sent
      # on, etc. It also provides behaviors to simplify bot development, like
      # the #reply method, which sends a message back to the same channel that
      # the original message was sent on. It works whether the command was sent
      # in a channel or a private query.
      #
      # The echo_back parameter is the text from our capture group in the match
      # macro above. Each capture group can be used as an additional parameter
      # to the command method.
      def command_echo(m, echo_back)
        # We just send back what we get
        m.reply echo_back
      end
    end
  end
end
```

We now have a fully functional echo plugin that we can use. To test it out we
need to (re)start JBot to load the latest version of the plugin. We can test it
out by joining the same channel as our bot and posting:

```
<you> !echo This is a test
```

You should then see:

```
<your-bot> This is a test
```

## Adding configurability

Now we want the ability to configure our plugin through `cinchize.yml`. It would
be nice if we could tell our plugin to downcase all the messages it echoes so
that no one can accuse it of shouting. Let's first add the code to pull in the
configuration data to our plugin. (Old comments are removed for brevity.)

```ruby
module Cinch
  module Plugins
    class Echo
      include Cinch::Plugin

      match /echo\s+(.*)/i, :method => :command_echo # !echo

      def initialize(*args)
        # We need to call the super constructor so that the Cinch framework will
        # automatically generate all of the bits we need, including populating
        # the data underneath the #config method.
        super

        # We are assigning to the @dont_shout attribute the value of the
        # :dont_shout option we set in cinchize.yml.
        @dont_shout = config[:dont_shout]
      end

      def command_echo(m, echo_back)
        # downcase if we don't want shouting
        echo_back.downcase! if @dont_shout
        m.reply echo_back
      end
    end
  end
end
```

Now in `cinchize.yml`, we edit our entry with our configuration.


```
---
# Plugins used for all configs
plugins: &plugins
  plugins:
  -
    class: "Cinch::Plugins::Echo"
    options:
      :dont_shout: true
  -
    class: ...
```

Now we can restart the bot to reload our config and plugin. Once the bot has
reconnected to the server, we can type the following into our channel:

```
<you> !echo I AM NOT SHOUTING
```

And we would see

```
<your-bot> i am not shouting
```

## Help dialogs

We now have an awesome plugin, but no one knows about it! We should add our
command to the `!help` command. In JBot, the help plugin automatically detects
help data in other plugins using a convention. For the general `!help` command,
the help plugin looks for a `#help` method on your plugin. That method should
return a string, one command per line, in the form:

```
!command - A blurb about what your comamnd does
```

For the extended `!help <command>` command, the help looks for a method named
`#help_<command>` where `<command>` is the name of your command. This method
should return a string of one or more lines with further details about the
command, like:

```
!command - A blurb about what your command does
  Usage: !command <parameters>
```

We should add our command to the help dialog so that people can find out about
our echo command.

```ruby
module Cinch
  module Plugins
    class Echo
      include Cinch::Plugin

      match /echo\s+(.*)/i, :method => :command_echo # !echo

      # The #help method does not take any parameters. It does not send the
      # message to the user. It merely provides the text to send. It is the job
      # of the help plugin to handle all that.
      def help
        # All we need here is just a string. If we had multiple commands in our
        # plugin, we would just return a string with each command on a new line
        # We have to provide the full help message, as the help plugin is not
        # smart enough to do all the magic (yet)
        '!echo - A command to echo back at you'
      end

      # The #help_echo method also does not take any parameters for the same
      # reasons that the #help method doesn't.
      def help_echo
        # We can use an array and join with newlines (as we are doing here), or
        # just interpolate a string, or whatever else to get a string back.
        # What's nice about the array is that we can put multiple output lines
        # on multiple code lines to make it clearer.
        [
          # We provide the original help text to provide context for the
          # extended help. If your plugin has only a single command in #help, we
          # could just as easily call #help here instead.
          '!echo - A command to echo back at you',
          # Here we are just providing usage info. We could also add more
          # information on more lines, but echo is pretty straightforward. The
          # help plugin automatically handles tabbing in the lines after the
          # first line, so we don't need to worry about doing that here.
          'Usage: !echo The text you want echoed back'
        ].join "\n"
      end

      def initialize(*args)
        super
        @dont_shout = config[:dont_shout]
      end

      def command_echo(m, echo_back)
        echo_back.downcase! if @dont_shout
        m.reply echo_back
      end
    end
  end
end
```

Now we can do `!help` and see our echo command in the help information. (Note:
The order of commands in the !help dialog is determined by the help plugin, so
your command may be first, last, or anywhere in between.)

```
...
<your-bot> !echo - A command to echo back at you
...
```

And we can do `!help echo`.

```
<your-bot> !echo - A command to echo back at you
<your-bot>   Usage: !echo The text you want echoed back
```

## Conclusion

We have seen how to create a basic plugin, and how to add more functionality,
including integrating with JBot's help system. Now that we have the basics down,
you can take a look at the other plugins in `lib/cinch/plugins/` to see how they
work.
