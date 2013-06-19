BANDASAUR
=========

Coming Soon!

Installation
---
1. Install RVM: https://rvm.beginrescueend.com
2. Add this to your ~/.profile: [[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
3. Run this: rvm install 1.9.2
4. Run this: rvm use 1.9.2
5. Install bundler: gem install bundler
6. Clone this repository: git clone git@github.com:kyledrake/bandasaur.git
7. In terminal, cd to bandasaur folder. RVM will ask you if you'd like to trust this folder, type yes.
8. In the bandasaur folder, run this: bundle install
9. Create the database. Create a config.yml (shown below) and populate it with the database login. Leave pool alone, and don't make the cookie secret empty.
10. Run this in the bandasaur folder: bundle exec rake db:bootstrap
11. Start it! Run this: bundle exec rackup -s thin
12. If you'd like to have it restart for development, run it with this instead: bundle exec shotgun -s thin -P static

Configuration
---

In your config.yml file:

    development:
      cookie_secret: AbCd3Fg
      database_configuration:
        adapter: mysql
        host: localhost
        username: root
        password:
        database: bandasaur
        pool: 10
    production: ect..