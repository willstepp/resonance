class Sound < ActiveRecord::Base
  attr_accessible :name, :filename, :filetype, :description
end
