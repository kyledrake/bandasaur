=begin
require 'openssl'

class User
  class RegistrationError < StandardError; end
  
  include DataMapper::Resource
  property :id,            Serial
  property :slug,          String, :index => true, :length => 10
  property :name,          String, :length => 150
  property :url_name,      String, :length => 50
  property :email,         String, :length => 255, :index => true
  property :is_band,       Boolean, :default => false
  property :password_hash, String, :length => 255
  property :password_salt, String, :length => 255
  property :city_id,       Integer
  property :state_id,      Integer
  property :country_id,    Integer
  property :view_count,    Integer, :default => 0
  property :created_at,    DateTime
  property :updated_at,    DateTime
  property :deleted_at,    DateTime
  property :source_id,     Integer, :required => true
  property :fma_artist_id, Integer
  
  has n, :songs
  has n, :genres, :through => Resource
  has n, :photos
  has n, :playlists
  has n, :friendships, :child_key => [:source_id]
  has n, :friends, self, :through => :friendships, :via => :target
  
  belongs_to :city
  belongs_to :state
  belongs_to :country
  belongs_to :source
  
  SLUG_LENGTH = 10
  
  before :create do
    self.source = Source.bandasaur unless self.source
    
    # SET THE SLUG
    until self.slug.nil? && self.class.count(:slug => self.slug) == 0
      self.slug = OpenSSL::Random.random_bytes((SLUG_LENGTH/2).to_i).unpack('H*').first
    end
    
  end
  
  PASSWORD_SALT_LENGTH = 10
  PASSWORD_MINUMUM = 4
  MAXIMUM_GENRES = 3

  validates_presence_of :name, :message => 'Please enter your name', :when => [:default, :fma]
  validates_format_of   :email, :as => :email_address, :message => 'Please enter a valid e-mail address', :when => [:default]
  validates_presence_of :city_id, :message => 'Please enter a city', :when => [:default]
  validates_presence_of :state_id, :message => 'Please enter a state', :when => [:default]
  validates_presence_of :country_id, :message => 'Please enter a country', :when => [:default]
  validates_with_method :valid_password?, :when => [:default]
  validates_with_method :valid_genres?, :when => [:default]
  
  def password_hash=(v); nil end
  def password_hash; nil end
  def password_salt=(v); nil end
  def password_salt; nil end
  
  def valid_password?
    return [false, 'Please enter a password'] if @passwords.nil? || @passwords['one'].empty?
    return [false, 'Passwords do not match'] if @passwords['one'] != @passwords['two']
    return [false, "Password must be greater than #{PASSWORD_MINUMUM} characters"] if @passwords['one'].length <= PASSWORD_MINUMUM
    true
  end
  
  def valid_genres?
    return [false, "Cannot have more than #{MAXIMUM_GENRES.en.numwords} genres"] if genres.length > MAXIMUM_GENRES
    true
  end
  
  def password=(passwords)
    @passwords = passwords
    attribute_set :password_salt, OpenSSL::Random.random_bytes((PASSWORD_SALT_LENGTH/2).to_i).unpack('H*').first
    attribute_set :password_hash, self.class.encrypt(attribute_get(:password_salt), passwords['one'])
  end
  
  def self.login(email, password)
    return nil if email.empty? || password.empty?
    user = first :email => email
    return nil if user.nil?
    user.password_correct?(password) ? user : nil
  end
  
  def password_correct?(password)
    self.class.encrypt(attribute_get(:password_salt), password) == attribute_get(:password_hash) ? true : false
  end
  
  def self.encrypt(salt, password); OpenSSL::Digest.hexdigest('sha512', "#{salt}#{password}") end
  def genre_ids=(genre_ids); genre_ids.each {|genre_id| genres << Genre.get(genre_id) } end
  def city_name=(name); self.city = City.from_name name end
  def state_name=(name); self.state = ::State.from_name name end
  def country_name=(name); self.country = Country.from_name name end
end
=end