class Sound < ActiveRecord::Base
  attr_accessible :name, :filename, :filetype, :description
  has_many :media, :dependent => :destroy
end
