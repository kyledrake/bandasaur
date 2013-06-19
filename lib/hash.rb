class Hash
  def to_query_string
    Rack::Utils.build_query self
  end
end