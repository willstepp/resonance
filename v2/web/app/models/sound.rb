class Sound < ActiveRecord::Base
  attr_accessible :name, :description, :uuid, :slug
  before_save :update_slug


  private

  def update_slug
    if !self.name.blank?
      self.slug = self.name.downcase.gsub(' ', '_').gsub('\'', '').gsub('-', '')
    end
  end
end
