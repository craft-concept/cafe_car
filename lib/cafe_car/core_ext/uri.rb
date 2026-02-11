require "uri"

URI::Generic.class_eval do
  def params
    Rack::Utils.parse_query(query)
  end

  def <(oth)
    oth = URI(oth)
    oth.path.start_with?(path) && params < oth.params
  end

  def >(oth) = URI(oth) == self || URI(oth) < self
end
