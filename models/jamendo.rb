require 'net/http'
require 'uri'
require 'tempfile'
require 'zlib'
require 'ostruct'
require 'uuid'
require 'pry'

class Jamendo

  DUMP_XML_URL = URI.parse 'http://img.jamendo.com/data/dbdump_artistalbumtrack.xml.gz'

  def self.import_xml_dump!(file_path=nil)
    Log.puts 'Beginning merge of Jamendo database...'

    DataMapper.logger.level = 99999 # Turn off SQL logger

    begin

      if file_path.nil?
        Log.puts "No dumpfile was specified, pulling directly from Jamendo's server..."
        Log.puts "Connecting to server..."
        tempfile_name = "jamendo_xml#{UUID.new.generate}.xml"
      else
        # FIXME
        # dbdump_file_gz = File.open file_path, :encoding => 'binary'
      end

      `curl -o "/tmp/#{tempfile_name}.gz" "#{DUMP_XML_URL.to_s}"`

      Log.puts "Decompressing..."
      `gunzip "/tmp/#{tempfile_name}.gz"`

      # gz = Zlib::GzipReader.new dbdump_file_gz.pat

      # while !gz.eof?
      #   dbdump_file.write gz.read(1024)
      # end

      reader = Nokogiri::XML::Reader File.open("/tmp/#{tempfile_name}", 'r')

      reader.each do |node|
        # node is an instance of Nokogiri::XML::Reader
        if node.name == 'artist'

          artist = Nokogiri::XML(node.outer_xml).xpath('//artist').first

          artist.children.each do |child|
            case child.name.to_sym
            when :id
              @artist = Artist.first_or_new :jamendo_id => child.text
            when :name  then @artist.name       = child.text
            when :url   then @artist.url        = child.text
            when :image then @artist.image      = child.text
            when :mbgid then @artist.mbg_id     = child.text
            end
          end

          artist.xpath('location').children.each do |child|
            case child.name.to_sym
              when :country then @artist.country = Country.first_or_create(:alpha_three => child.text)
              when :state   then @artist.subdivision = Subdivision.first_or_create(:code => child.text, :country => @artist.country)
              when :city    then @artist.city = City.first_or_create :name => child.text, :subdivision => @artist.subdivision
            end
          end
          @artist.save
          Log.print "A"

          artist.xpath('Albums/album').each do |album|
            @album = Album.new :artist => @artist
            album.children.each do |child|
              case child.name.to_sym
                when :id
                  @album = Album.first_or_new :jamendo_id => child.text, :artist => @artist
                when :name            then @album.name = child.text
                when :url             then @album.url = child.text
                when :mbgid           then @album.mbgid = child.text
                when :license_artwork then @album.license_artwork = child.text
                when :releasedate     then @album.releasedate = DateTime.parse(child.text) # FIXME: This is not retaining the timezone!
                when :filename        then @album.filename = child.text
                when :id3genre        then @album.genre = Genre.first(:id3_id => child.text)
              end
            end
            @album.save
            Log.print "M"

            album.xpath('Tracks/track').each do |track|
              track.children.each do |child|
                case child.name.to_sym
                  when :id
                    @track = Track.first_or_new :jamendo_id => child.text, :album => @album
                  when :name     then @track.name = child.text
                  when :filename then @track.file_name = child.text
                  when :mbgid    then @track.mbg_id = child.text
                  when :numalbum then @track.num_album = child.text
                  when :license  then @track.license = child.text
                  when :id3genre then @track.genre = Genre.first(:id3_id => child.text)
                end
              end
              @track.save
              Log.print "T"

              track.xpath('Tags/tag').each do |tag|
                tag.children.each do |child|
                  case child.name.to_sym
                    when :idstr  then @tag = Tag.first_or_create :name => child.text
                    when :weight
                      begin
                        Tagging.first_or_create :tag => @tag, :track => @track, :weight => child.text.to_f
                      rescue DataObjects::IntegrityError
                      end
                  end
                end
              end
            end
          end
        end
      end

    ensure
      FileUtils.rm "/tmp/#{tempfile_name}"
    end

    Log.puts "\nCompleted! #{Artist.count} artists, #{Track.count} tracks, #{City.count} cities, #{Subdivision.count} subdivisions, #{Country.count} countries."
  end

  def self.import_country_names!
    Log.puts "Importing country names..."
    require 'csv'
    # Import Country ISO CSV.
    CSV.parse(RestClient.get('http://clickandclackareterrorists.s3.amazonaws.com/wikipedia-iso-country-codes.csv')).each_with_index do |row,i|
      next if i == 0
      country = Country.first :alpha_three => row[2]
      country.update :name => row[0], :alpha_two => row[1] unless country.nil?
      # Country.create :name => row[0], :alpha_two => row[1], :alpha_three => row[2], :numeric_code => row[3]
    end

    # FXX France, Metropolitan — Reserved on request of France; Officially assigned before deleted from ISO 3166-1
    fxx = Country.first(:alpha_three => 'FXX')
    fxx.update :name => 'France, Metropolitan' if fxx

    Log.puts "Completed! Out of #{Country.count} country records, #{Country.count(:name.not => nil)} now have names."
  end

  def self.import_subdivision_names!
    Log.puts 'Importing subdivision names...'
    require 'csv'
    CSV.parse(RestClient.get('http://clickandclackareterrorists.s3.amazonaws.com/isostates.csv')).each_with_index do |row,i|
      next if i == 0
      next unless row[0].nil?
      next if row[1].nil?
      @subdivision = Subdivision.first :code => row[1].split('-').last, :'country.alpha_two' => row[1].split('-').first
      if @subdivision
        @subdivision.update(:name => row[3])
      else
        # Log.puts("No code found for #{row[3]}, skipping...")
      end
    end
    Log.puts "Completed! Out of #{Subdivision.count} country records, #{Subdivision.count(:name.not => nil)} now have names."
  end

  def self.import_id3_genres!
    Log.puts 'Importing ID3 Genres'
    # Import ID3 Genres. Reference: http://www.linuxselfhelp.com/HOWTO/MP3-HOWTO-13.html#ss13.3
    CSV.read(File.join(Bandasaur.root, 'data', 'id3_genres.txt'), :encoding => 'UTF-8').each_with_index do |row,i|
      id3_id, name = row.first.split '.'
      genre = Genre.new :id3_id => id3_id, :name => name
      genre.is_winamp_extension = true if id3_id.to_i >= 80
      genre.save
      Log.print 'G'
    end
    Log.puts ''
  end
end
