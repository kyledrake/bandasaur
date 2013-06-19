class Album
  include DataMapper::Resource
  property :id, Serial
  property :jamendo_id, Integer, :index => true
  property :name, String, :length => 255
  property :url, String, :length => 255
  property :mbgid, String, :length => 255
  property :license_artwork, String, :length => 255
  property :releasedate, DateTime
  property :filename, String, :length => 255
  has n, :tracks
  belongs_to :artist
  belongs_to :genre, :required => false
end
