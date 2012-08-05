class Sound
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :desc
  field :app_id, :type => Integer

  after_create :set_app_id

  private 

  #note: in a highly concurrent system this might fail,
  #but I don't think we should worry about that for creating sounds
  def set_app_id
  	self.app_id = Sound.count
  	self.save
  end
end