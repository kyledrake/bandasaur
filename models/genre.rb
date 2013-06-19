class Genre
  include DataMapper::Resource
  property :id, Serial
  property :id3_id, Integer, :index => true
  property :name, String
  property :is_winamp_extension, Boolean, :default => false
  property :tracks_count_cache, Integer, :index => true
  has n, :tracks
  has n, :albums

  def self.all_with_tracks(track_count=0)
    all :tracks_count_cache.gt => track_count, :order => :name
  end

  def self.original; all :is_winamp_extention => false, :order => :name end

  def self.update_tracks_count_cache!
    # There is a bug in the collection object where it tries to pull all tracks, so this less terse version is a workaround.
    genre_ids = all.collect {|genre| genre.id}
    genre_ids.each {|genre_id| (genre = get(genre_id)).update :tracks_count_cache => genre.tracks.count}
  end

  def self.to_hash
    genres = {}
    all(order: 'name').each {|genre| genres[genre.id] = genre.name}
    genres
  end
end
