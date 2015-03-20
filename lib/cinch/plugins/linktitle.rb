require 'nokogiri'
require 'eat'
require 'openssl'

class LinkTitle

  include Cinch::Plugin

  match /(https?\:\/\/.*?)(\s|$)/, use_prefix: false

  # Default list of URL regexps to ignore.
  DEFAULT_BLACKLIST = [/\.png$/i, /\.jpe?g$/i, /\.bmp$/i, /\.gif$/i, /\.pdf$/i, /\.doc$/i, /\.ppt$/i, /\.odt$/i, /\.xls$/i, /\.zip$/i, /\.mp3$/i, /\.m4a$/i, /\.ogg$/i, /\.wav$/i, /\.mp4$/i, /\.m4v$/i, /\.mov$/i, /\.wmv$/i, /\.avi$/i, /\.mpe?g$/i, /\.ogv$/i, /\.3gp$/i, /\.3g2$/i].freeze

  def execute(m, url)
    blacklist = DEFAULT_BLACKLIST.dup
    blacklist.concat(config[:blacklist]) if config[:blacklist]

    return if blacklist.any?{|entry| url =~ entry}
    site = Nokogiri::HTML(eat(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))
    title = site.css('title').text.strip
    title = title.gsub(/\s+/, ' ').strip
    puts title.inspect
    if url.length < 30
      if title.length > 200
        title = title[0..200] + "... [Truncated]"
        m.reply '^ ' + title unless title.empty?
      else
        m.reply '^ ' + title unless title.empty?
      end
    elsif
      if title.length > 200
        title = title[0..200] + "... [Truncated]"
        m.reply '^ ' + title unless title.empty?
      else
        m.reply '^ ' + title unless title.empty?
      end
    else
      m.reply '^ No title or could not fetch title.'
    end
  end
end

