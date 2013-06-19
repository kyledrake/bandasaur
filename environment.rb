Encoding.default_internal = 'UTF-8'
require 'rubygems'
Bundler.require
Dir.glob(['lib', 'models'].map! {|d| File.join File.expand_path(File.dirname(__FILE__)), d, '*.rb'}).each {|f| require f}
require File.join(File.expand_path(File.dirname(__FILE__)), 'helpers.rb')

class Sinatra::Base
  set :static, true
  set :root, File.expand_path(File.dirname(__FILE__))
  set :public, File.join(root, 'static')
  set :dump_errors, true
  set :erubis, :escape_html => true

  configure do
    if development?
      Bundler.require :development
      DataMapper::Logger.new $stdout, :debug
    end
    ::Log = SimpleLog.new
    # Read in config.yml. This file is NOT CHECKED INTO GITHUB, so that our secret keys and passwords are not revealed. See the docs.
    BandasaurConfig = SymbolTable.new YAML.load(File.read(File.join(root, 'config.yml')))[environment.to_s]
    DataMapper.setup :default, BandasaurConfig.database_configuration
    DB::Base.establish_connections BandasaurConfig.database_configuration
  end

  configure :test do
    require 'test/unit'
    require 'minitest/spec'
    Bundler.require :test
    DataMapper.auto_migrate!
    Log.disable
  end

  use Rack::FiberPool
  use Rack::MethodOverride
  use Rack::Session::Cookie, :key => 'bandasaur.session',
                             :path => '/',
                             :expire_after => 2592000, # In seconds
                             :secret => BandasaurConfig.cookie_secret
  helpers Helpers
  register Sinatra::Namespace
  register Sinatra::R18n
end

require File.join(Sinatra::Base.root, 'bandasaur.rb')
