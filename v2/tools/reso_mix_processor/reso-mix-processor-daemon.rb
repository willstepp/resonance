require 'rubygems'
require 'bundler/setup'
require 'daemons'

Daemons.run('reso-mix-processor-scheduler.rb')