require 'socket'
require 'timeout'

class Ircd
  WAIT_FOR_INPUT = 3 # Wait this many seconds for input
  WAIT_FOR_FLUSH = 2 # Wait this many seconds for flushing input

  attr_reader :tester_nick
  attr_reader :cinch_nick
  attr_reader :channel

  def initialize(cinch_nick = "jbot-test", channel = "#jb-test")
    @server_socket = TCPServer.new 6667
    @socket = nil
    @client_connected = false
    @tester_nick = "testrunner"
    @cinch_nick = cinch_nick
    @channel = channel
  end

  def client_connected?
    @client_connected
  end

  def accept_client
    @socket = @server_socket.accept
    expect_to_get "CAP LS"
    expect_to_get "NICK #{cinch_nick}"
    expect_to_get "USER cinch 0 * :cinch"
    puts ":localhost CAP * LS :away-notify multi-prefix"
    expect_to_get "CAP REQ :away-notify multi-prefix"
    server_send "CAP", "ACK :away-notify multi-prefix"
    expect_to_get "CAP END"
    server_send "001", ":Welcome #{cinch_nick}!~cinch@localhost"
    server_send "002", ":Your host is localhost, running testrunner"
    server_send "003", ":This server was created Sat Jan 10 2015 at 17:24:49 CET"
    server_send "004", "localhost Unreal3.2.10.3-gs iowghraAsORTVSxNCWqBzvdHtGpIDc lvhopsmntikrRcaqOALQbSeIKVfMCuzNTGjUZ"
    server_send "005", "CMDS=KNOCK,MAP,DCCALLOW,USERIP UHNAMES NAMESX SAFELIST HCN MAXCHANNELS=100 CHANLIMIT=#:100 MAXLIST=b:60,e:60,I:60 NICKLEN=30 CHANNELLEN=32 TOPICLEN=307 KICKLEN=307 AWAYLEN=307 :are supported by this server"
    server_send "005", "MAXTARGETS=20 WALLCHOPS WATCH=128 WATCHOPTS=A SILENCE=15 MODES=12 CHANTYPES=# PREFIX=(qaohv)~&@%+ CHANMODES=beI,kfL,lj,psmntirRcOAQKVCuzNSMTGUZ NETWORK=GeekShed CASEMAPPING=ascii EXTBAN=~,qjncrRaT ELIST=MNUCT :are supported by this server"
    server_send "005", "STATUSMSG=~&@%+ EXCEPTS INVEX :are supported by this server"
    join_channel channel

    @client_connected = true
  end

  def disconnect_client
    @socket.close unless @socket.nil?
    @socket = nil
    @client_connected = false
  end

  def gets timeout = WAIT_FOR_INPUT
    read(timeout).strip
  end

  def read timeout = WAIT_FOR_INPUT
    Timeout::timeout(timeout) do
      @socket.gets
    end
  end

  def puts msg
    write "#{msg}\r\n"
  end

  def write msg
    @socket.write msg
  end

  def server_send command, msg
    puts ":localhost #{command} #{cinch_nick} #{msg}"
  end

  def tester_send channel, msg
    puts ":#{tester_nick}!~#{tester_nick}@localhost PRIVMSG #{channel} :#{msg}"
  end

  def tester_send_channel msg
    tester_send channel, msg
  end

  def tester_send_bot msg
    tester_send cinch_nick, msg
  end

  def join_channel channel
    expect_to_get "JOIN #{channel}"
    puts ":#{cinch_nick} MODE #{cinch_nick} +iRx"
    puts ":#{cinch_nick}!~cinch@localhost JOIN #{channel}"
    server_send "332", "#{channel} :"
    expect_to_get "WHO #{channel}"
    server_send "353", "= #{channel} :#{cinch_nick} @#{tester_nick}"
    server_send "366", "#{channel} :End of /NAMES list."
    server_send "352", "#{channel} ~cinch localhost localhost #{cinch_nick} H :0 cinch"
    server_send "352", "#{channel} ~#{tester_nick} localhost localhost #{tester_nick} Hr@ :0 #{tester_nick}"
    server_send "315", "#{channel} :End of /WHO list."
    server_send "368", "#{channel} :End of Channel Ban List"
    server_send "324", "#{channel} +ntr"
    server_send "329", "#{channel} 1414677535"
    server_send "387", "#{channel} :End of Channel Owner List"

    # Sometimes the cinch bot will send two additional MODE lines after
    # connecting. We haven't nailed down what triggers these lines to be sent or
    # not be sent, so this is a work-around that will just skip those lines on
    # read if we see them.
    # TODO: Fix me when we figure out what triggers the MODE lines to be sent
    begin
      expect_to_get "MODE #{channel} +b"
      expect_to_get "MODE #{channel}"
    rescue Timeout::Error => timeout_error
      # Do nothing
    end
  end

  # This method reads in any straggling messages received, and discards them. It
  # is VERY slow, and should probably be fixed with something better.
  # TODO: Flushing the read buffer is TOO SLOW
  def flush_read
    begin
      loop { read WAIT_FOR_FLUSH }
    rescue Timeout::Error => timeout_error
      # We're done, do nothing
    end
  end

  def close
    disconnect_client
    @server_socket.close
  end

  private

  def expect_to_get expected
    actual = gets WAIT_FOR_FLUSH
    if expected != actual
      raise "Expected \"#{expected}\", but got \"#{actual}\""
    end
  end
end
