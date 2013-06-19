class Artist
  include DataMapper::Resource
  property :id, Serial
  property :jamendo_id, Integer, :index => true
  property :name, String, :length => 255
  property :url, String, :length => 255
  property :image, String, :length => 255
  property :mbg_id, String, :length => 255
  belongs_to :city, :required => false
  belongs_to :subdivision, :required => false
  belongs_to :country, :required => false
end
