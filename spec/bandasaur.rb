require File.join File.expand_path(File.dirname(__FILE__)), 'environment.rb'

describe Bandasaur do
  include Rack::Test::Methods
  def app; Bandasaur end
  
  describe 'the index route' do
    it 'should load correctly' do
      get '/'
      last_response.ok?.must_equal true
      (last_response.body.length > 0).must_equal true
    end
  end
end