# A class to hold the data for a Show, woah

class Show
  attr_reader :title, :url, :rss, :aliases

  def initialize(json_hash)
    @title = json_hash["title"]
    @url = json_hash["url"]
    @rss = json_hash["rss"]
    @aliases = (json_hash["aliases"] || []).map do |show_alias|
      show_alias.downcase
    end
  end

  def matches?(search_term)
    search_term = search_term.downcase

    matches_alias?(search_term) || matches_url?(search_term) || matches_title?(search_term)
  end

  private

  def matches_url?(search_term)
    url.downcase == search_term
  end

  def matches_title?(search_term)
    title.downcase.include? search_term
  end

  def matches_alias?(search_term)
    aliases.include? search_term
  end
end
