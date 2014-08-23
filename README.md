# BBlog

A basic blog in Ruby (exercise)

## Setup

These are the steps to set up the blog:

1. Run `bundle install` to install the gems
2. Start up Postgres
3. Run `./setup` to set up the database and migrate the tables. Setup also creates a default user 'admin@blog' with password '123'
4. Run `./start` to start the server in development mode. Run `./start production` to start the server in production mode (daemonized)
5. Run `./stop production` to stop the server in production mode. To stop the server in development mode, just press Ctrl-C


