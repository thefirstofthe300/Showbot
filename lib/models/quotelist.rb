class QuoteList
  attr_reader :quotes
  def initialize(quotes)
    @quotes = quotes
  end

  def quote_for(name)
    canonical_name = canonicalize name
    return '' if !canonical_name
    @quotes[canonical_name][:quotes].sample
  end

  def add(name, quote)
    canonical_name = canonicalize name
    return '' if !canonical_name
    @quotes[canonical_name][:quotes] << quote
  end

  def del(name, quote)
    canonical_name = canonicalize name
    return '' if !canonical_name
    @quotes[canonical_name][:quotes].delete(quote)
  end

  private

  def canonicalize(name)
    name.downcase!

    @quotes.select do |canonical, value|
      match_canonical?(canonical, name) || in_aliases?(value[:aliases], name)
    end.keys.first
  end

  def match_canonical?(canonical, name)
    canonical.downcase == name
  end

  def in_aliases?(aliases, name)
    Array(aliases).map(&:downcase).any? do |element|
      element.downcase == name
    end
  end
end
