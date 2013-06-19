class Country
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :alpha_three, String, :length => 3, :index => true
  property :alpha_two, String, :length => 2, :index => true
  property :tracks_count_cache, Integer
  has n, :subdivisions
  has n, :artists

  def self.update_tracks_count_cache!
    all.each {|country| country.update_tracks_count_cache!}
  end

  def update_tracks_count_cache!
    update :tracks_count_cache => repository.adapter.select("select count(*) from tracks
                                                             join albums on tracks.album_id=albums.id
                                                             join artists on albums.artist_id=artists.id
                                                             where country_id=#{id}").first
  end
  
  def self.to_hash
    countries = {}
    all(order: 'name').each {|country| countries[country.id] = country.name}
    countries
  end
end
