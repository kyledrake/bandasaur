class Track
  class Query
    def initialize(options={})
      @joins = []
      @conditionals = []
      genres options['genre_ids']
      countries options['country_ids']
    end

    def genres(genre_ids)
      return if genre_ids.nil?
      @joins << 'INNER JOIN genres ON tracks.genre_id=genres.id'
      @conditionals << '('+genre_ids.map {|genre_id| "tracks.genre_id=#{DB::Base.e genre_id}"}.join(' OR ')+')'
    end

    def countries(country_ids)
      return if country_ids.nil?
      @joins << 'INNER JOIN albums ON tracks.album_id=albums.id'
      @joins << 'INNER JOIN artists ON albums.id=artists.id'
      @conditionals << '('+country_ids.map {|country_id| "artists.country_id=#{DB::Base.e country_id}"}.join(' OR ')+')'
    end

    def get_ids
      query =  "SELECT tracks.id AS id FROM tracks"
      query += " #{@joins.join(' ')}" unless @joins.empty?
      query += " WHERE #{@conditionals.join ' AND '}" unless @conditionals.empty?
      query
    end
  end

  def self.search(o)
    o ||= {}
    query = Query.new o
    slugs = []
    puts query.get_ids
    result_handler = DB::Base.all query.get_ids

    if result_handler.num_rows < 300
      while row = result_handler.fetch_row do
        slugs << row.first
      end
      slugs.sort_by! {rand}
    else
      300.times { slugs << result_handler.data_seek(rand(result_handler.num_rows)).fetch_row.first }
    end
    slugs
  end
end
