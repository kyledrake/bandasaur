class Subdivision
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 100
  property :code, String, :length => 4, :index => true
  belongs_to :country
  has n, :cities
  has n, :artists
end
