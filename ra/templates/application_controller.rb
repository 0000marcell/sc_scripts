class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery
	private

		def doorkeeper_unauthorized_render_options(error: nil)
			{ json: { error: "Not authorized!" } }	
		end
		
		def current_resource_owner
			User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
		end
end
