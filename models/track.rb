class Track
  include DataMapper::Resource
  property :id, Serial
  property :jamendo_id, Integer, :index => true
  property :album_id, Integer
  property :genre_id, Integer, :index => true
  property :name, String, :length => 255
  property :file_name, String, :length => 255
  property :mbg_id, String, :length => 255
  property :num_album, String, :length => 255
  property :license, String, :length => 255
  belongs_to :album
  belongs_to :genre
  has n, :taggings
  has n, :tags, :through => :taggings

  def to_json(opts={})
    j = {'id' => id, 'name' => name.clean_up, 'artist_name' => album.artist.name.clean_up, 'file_url' => file_url}
    j['genres'] = {'id' => genre.id, 'name' => genre.name} if genre
    j['city'] = album.artist.city.name if album.artist.city
    j['subdivision'] = album.artist.subdivision.name if album.artist.subdivision
    j['country'] = album.artist.country.name if album.artist.country
    opts[:to_json] == false ? j : j.to_json
  end

  def file_url; "http://api.jamendo.com/get2/stream/track/redirect/?id=#{jamendo_id}&streamencoding=mp31" end
end