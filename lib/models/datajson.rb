require 'json'

class DataJSON
  attr_reader :slug
  attr_reader :title
  attr_reader :started_at

  def initialize(path)
    @live = false
    @written = false
    @data_json = File.join File.dirname(__FILE__), "../../#{path}"
    read
  end

  def read
    json = nil

    open(@data_json, 'r') do |file|
      json = JSON.load file
    end

    raise "DataJSON could not be parsed." if json.nil?

    self.live = json[:live]
    if !json[:broadcast].nil?
      self.slug = json[:broadcast][:slug]
      self.title = json[:broadcast][:title]
      @started_at = json[:broadcast][:started_at]
    end

    @written = true
  end

  def written?
    @written
  end

  def write
    @started_at = DateTime.now

    open(@data_json, 'w') do |file|
      file.write to_json
    end

    @written = true
  end

  def live?
    @live
  end

  def live=(live)
    @live = !!live
    @written = false
  end

  def slug=(slug)
    @slug = slug
    @written = false
  end

  def title=(title)
    @title = title
    @written = false
  end

  def to_json(*args)
    data = {
      :live => live?
    }

    if live?
      data[:broadcast] = {
        :slug => slug,
        :title => title,
        :started_at => started_at
      }
    end

    data.to_json(args)
  end

  def start_show(show)
    self.live = true
    self.slug = show.url
    self.title = show.title
    write
  end

  def end_show
    self.live = false
    self.slug = nil
    self.title = nil
    write
  end
end
