class ApiController < ApplicationController
	def get_sounds
		@sounds = Sound.all
    	@counter = 0
    	respond_to do |format|
        	format.json { render :partial => "api/get_sounds.json" }
    	end
	end
end