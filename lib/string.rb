class String
  def url_friendly
    self.downcase.gsub(/[^a-z0-9]+/i, '-')
  end
  
  def clean_up
    gsub(/_|\.|\//, ' ').gsub(/\b('?[a-z])/) { $1.capitalize }
  end
  
end