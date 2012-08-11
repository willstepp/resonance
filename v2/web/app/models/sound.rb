class Sound
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :desc

  field :app_id
  after_create :set_app_id

  private 

  def set_app_id
  	self.app_id = "#{self.created_at.strftime("%Y%m%d%H%M")}_#{self.name.gsub(/[^0-9a-z ]/i, '').gsub(' ', '_').downcase}"
  	self.save
  end
end