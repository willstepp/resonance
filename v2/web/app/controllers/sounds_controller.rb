class SoundsController < ApplicationController
	def index
		@s = Sound.new
		@s.name = "steam_in_a_forest.mp3"
		@s.desc = "A soothing blend of stream and forest"
		@s.save

		@count = Sound.count
	end
end
