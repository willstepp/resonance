require 'rufus/scheduler'

require_relative 'reso-db-backup'

scheduler = Rufus::Scheduler.start_new

#every day at 0600 (UTC)
scheduler.cron '0 6 * * *' do
  ResoDbBackup.run
end

scheduler.join