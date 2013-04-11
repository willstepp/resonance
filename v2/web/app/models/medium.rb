class Medium < ActiveRecord::Base
  attr_accessible :filename, :type
  belongs_to :sound
end
