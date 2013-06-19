namespace :db do
  def init_environment
    require File.join(File.expand_path(File.dirname(__FILE__)), 'environment.rb')
    Bundler.require :rake
    require 'csv'
  end

  desc 'Bootstrap and re-populate database, takes a while, be patient (example: be rake db:bootstrap RACK_ENV=development)'
  task :bootstrap do
    init_environment
    Log.puts 'Bootstrapping database...'
    DataMapper.auto_migrate!
    Jamendo.import_id3_genres!
    Jamendo.import_xml_dump!
    Jamendo.import_country_names!
    Jamendo.import_subdivision_names!
    Genre.update_tracks_count_cache!
    Country.update_tracks_count_cache!
  end

  desc 'non-destructive migration of the database (example: be rake db:migrate RACK_ENV=development)'
  task :migrate do
    init_environment
    Log.puts 'Migrating database...'
    DataMapper.auto_upgrade!
  end

  desc 'Pull nightly database dump from Jamendo and merge with database'
  task :jamendo_import do
    init_environment
    DataMapper::Model.raise_on_save_failure = true
    Jamendo.import_xml_dump!
    Genre.update_tracks_count_cache!
    Country.update_tracks_count_cache!
  end

  desc 'Update the column that caches how many tracks each genre has, used to remove genres from list'
  task :update_genre_tracks_count_cache do
    init_environment
    Log.puts 'Updating the genre track count cache...'
    Genre.update_tracks_count_cache!
  end

  desc 'Update the column that caches how many tracks each country has'
  task :update_country_tracks_count_cache do
    init_environment
    Log.puts 'Updating the country track count cache...'
    Country.update_tracks_count_cache!
  end
end
