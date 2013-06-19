class City
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 255
  belongs_to :subdivision
  has n, :artists
end
