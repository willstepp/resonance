require 'rufus/scheduler'

require_relative 'reso-backup'

scheduler = Rufus::Scheduler.start_new

#every weekday at 0600 (UTC)
scheduler.cron '0 6 * * *' do
  ResoBackup.run
end

scheduler.join