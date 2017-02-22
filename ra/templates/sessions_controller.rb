class Api::V1::SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:username].downcase)
		if user && user.authenticate(params[:password]) &&
      user.activated?
      token = Doorkeeper::AccessToken.create(
        resource_owner_id: user.id,
        application_id: '1',
        expires_in: 24.hours,
        scopes: 'public'
      )
      json = {access_token: token.token, token_type: token.token_type, 
              expires_in: token.expires_in, created_at: token.created_at.to_i, 
              user: { id: user.id, email: user.email, name: user.name , username: user.username}
      }
      render json: json
    else
      if user.nil?
        msg = "This user doesn't exist!"
      elsif !user.authenticate(params[:password])
        msg = "Wrong password!"
      elsif !user.activated?
        msg = "User isn't activated, please verify your email to activate the user!"
      else
        msg = "Unknow error!"
      end
      render json: {error_description: msg}, status: 422
    end
  end
end
