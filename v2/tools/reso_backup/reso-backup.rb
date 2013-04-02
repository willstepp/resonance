require 'logger'

require_relative 'settings'

module ResoBackup
  def self.run
    puts Settings.db.host
    puts Settings.db.username
  end
end