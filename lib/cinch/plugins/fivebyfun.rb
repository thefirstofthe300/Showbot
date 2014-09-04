# The stuff that makes showbot so nice to be around.

module Cinch
  module Plugins
    class FiveByFun
      include Cinch::Plugin

      # Hosts
      match /(chris|chrislas)/i,           :method => :command_chris
      match /(angpaddle|angela|fauxang)/i, :method => :command_angela
      match /(allan)/i,                    :method => :command_allan
    # match /(mars_base)/i,                :method => :command_marsbase

      # Etc.
      match /(eight_ball|8ball)/i,         :method => :command_eight_ball
      match /(mumble)/i,                   :method => :command_mumble
      match /(irc)/i,                   :method => :command_irc
      match /(RMS)/i,                   :method => :command_rms

      def command_mumble(m)
        m.reply "Mumble info - Server: mumble.jupitercolony.com, Port: 64734"
      end

      def command_irc(m)
        m.reply "IRC info - Server: irc.geekshed.net, Channel: #jupiterbroadcasting"
      end

      def command_rms(m)
        m.reply ["It's negative in the freedom... dimension. - Via http://youtu.be/radmjL5OIaA",
        "Get it out of here!",
        "...and the value of this is negative."].sample
      end

      def command_angela(m)
        m.reply ["I'm super, like, way less fat.",
        "The FauxShow is not a real show, it's a social experience! - Via http://www.youtube.com/playlist?list=PL73AAFA51E9BBABFA",
        "Oh no, looks like you accidentally the whole thing",
        "So you take the chicken breast, which is a mommy chicken. then you dip it in her BABY!",
        "I accidentally the WHOLE thing",
        "Let's do ALL THE THINGS!",
        "Ain't nobody got time for dat",
        "Allan knows about his breastmilk. - Via TechSNAP postshow",
        "Literacy is good... And so is power... - Via http://youtu.be/HIEaSaMnqF0",
        "There are many tricks we use in show is, and one of them is unbuttoning yer pants - Via http://youtu.be/-tV15c4ZGnY",
        "Follow me on instagram www.instagram.com/momvault"].sample
      end

      def command_allan(m)
        m.reply "It's just enough buzz word and close enough to be right but not. That would be in the knows enough to be dangerous box - Via http://youtu.be/tj_oblimlLo#t=2221"
      end

      def command_chris(m)
        m.reply ["Oh hm... yeah... The dick scraper? - Via http://youtu.be/wxr-u34qSMU",
        "BIG SHOW, guys! - Via http://youtube.com/playlist?list=PL995EBE645950DFF5",
        "Sometimes I hope the computer understands that I can, and will take it apart. - (While editing TechSNAP 137)",
        "Buy when it goes up, not when it goes down. You never try to catch a falling knife. - Via LAS Pre show S29 E9"].sample
      end

      def command_eight_ball(m)
        m.reply ["It is certain",
          "It is decidedly so",
          "Without a doubt",
          "Yes - definitely",
          "You may rely on it",
          "As I see it, yes",
          "Most likely",
          "Outlook good",
          "Signs point to yes",
          "Yes",
          "Reply hazy, try again",
          "Ask again later",
          "Better not tell you now",
          "Cannot predict now",
          "Concentrate and ask again",
          "Don't count on it",
          "My reply is no",
          "My sources say no",
          "Outlook not so good",
          "Very doubtful"].sample
      end
    end
  end
end

