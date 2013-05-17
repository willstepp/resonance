require 'rufus/scheduler'

require_relative 'reso-mix-processor'

scheduler = Rufus::Scheduler.start_new

#every minute
scheduler.cron '* * * * *', :allow_overlapping => false do
  ResoMixProcessor.run
end

scheduler.join