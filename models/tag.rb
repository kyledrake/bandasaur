class Tag
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 255
  has n, :taggings
  has n, :tracks, :through => :taggings
end
