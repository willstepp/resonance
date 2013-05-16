require 'rubygems'
require 'bundler/setup'
require 'daemons'

Daemons.run('reso-db-backup-scheduler.rb')