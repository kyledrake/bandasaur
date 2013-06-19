require File.join File.expand_path(File.dirname(__FILE__)), 'environment.rb'

FakeWeb.register_uri :get, Jamendo::DUMP_XML_URL, :body => File.read(File.join(File.expand_path(File.dirname(__FILE__)), 'files', 'jamendo_dump_test.xml.gz'))

describe Jamendo do
  describe "the XML importer" do
    before do
      DataMapper.auto_migrate!
    end
    it "should use Jamendo servers by default" do
      Jamendo.import_xml_dump!
      Artist.count.must_equal 2
      Track.count.must_equal 85
      City.count.must_equal 2
      Subdivision.count.must_equal 2
      Country.count.must_equal 2
    end
    
    it "should use local file if provided" do
      Jamendo.import_xml_dump! File.join(File.expand_path(File.dirname(__FILE__)), 'files', 'jamendo_dump_test.xml.gz')
      Artist.count.must_equal 2
      Track.count.must_equal 85
      City.count.must_equal 2
      Subdivision.count.must_equal 2
      Country.count.must_equal 2
    end
  end
end