require "em-synchrony/em-mysqlplus"

module DB
  class Base
    def self.all(query); @@db.query query end
    def self.e(text); @@db.escape_string text end
    
    def self.establish_connections(config = {})
      EM.next_tick do
        @@db = EventMachine::Synchrony::ConnectionPool.new(size: config[:pool] || 1) do
          EventMachine::MySQL.new host: config[:host], user: config[:username], password: config[:password], database: config[:database]
        end
      end
    end
  end
end
