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
    name.downcase!
    @quotes[name] ||= {aliases:[], quotes:[]}
    if @quotes[name][:quotes].select {|q| q.downcase == quote.downcase} == []
      @quotes[name][:quotes] << quote
    else
      ''
    end
  end

  def del(name, quote)
    canonical_name = canonicalize name
    return '' if !canonical_name
    @quotes[canonical_name][:quotes].delete(quote)
    @quotes.delete(canonical_name) if @quotes[canonical_name][:quotes].length == 0
  end

  def add_alias(name, a)
    canonical_name = canonicalize name
    return '' if !canonical_name
    @quotes[canonical_name][:aliases] << a
  end

  def del_alias(name, a)
    canonical_name = canonicalize name
    return '' if !canonical_name
    @quotes[canonical_name][:aliases].delete(a)
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
