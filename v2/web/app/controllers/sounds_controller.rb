class SoundsController < ApplicationController
	def index
		@s = Sound.new
		@s.name = "steam_in_a_forest.mp3"
		@s.save

		@count = Sound.count
	end
end
