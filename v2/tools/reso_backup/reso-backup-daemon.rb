require 'rubygems'
require 'bundler/setup'
require 'daemons'

Daemons.run('reso-backup-scheduler.rb')