class Tagging
  include DataMapper::Resource
  property :tag_id, Integer, :key => true, :min => 1
  property :track_id, Integer, :key => true, :min => 1
  property :weight, Float
  belongs_to :tag, :key => true
  belongs_to :track, :key => true
end
