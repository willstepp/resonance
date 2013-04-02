require 'rufus/scheduler'

require_relative 'reso-backup'

scheduler = Rufus::Scheduler.start_new

#every weekday at 0000 (UTC)
scheduler.cron '0/2 * * * *' do
  ResoBackup.run
end

scheduler.join