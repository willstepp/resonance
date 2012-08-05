class HomeController < ApplicationController
	layout :resolve_layout

	def index
	end

	private

	def resolve_layout
	  case action_name
	  when "index"
	    nil
	  else
	    "application"
	  end
	end
end
