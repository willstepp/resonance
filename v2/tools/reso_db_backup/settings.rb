require 'settingslogic'

class Settings < Settingslogic
  source "#{File.join(File.expand_path(File.dirname(__FILE__)), "./settings.yml")}"
end