class Api::V1::PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
	before_action :valid_user, only: [:edit, :update]
	before_action :check_expiration, only: [:edit, :update]
	
	def create
	  @user = User.find_by(email: params[:user][:email].downcase)
		if @user
			@user.create_reset_digest
      @user.create_reset_url("#{request.headers['origin']}/password-reset")
			@user.send_password_reset_email
			render json: @user
		else
			render json: {error: 'user not found' }, status: 404
		end
	end

  def edit
  end

	def update
    if @user.update_attributes(user_params)
      render json: @user
    else
      render json: { error: "The password wasn't updated!" }, status: 404
    end
	end

	private
		
		def user_params	
			params.require(:user).permit(:password, :password_confirmation)
		end

		def get_user
			@user = User.find_by(email: params[:user][:email])
		end

		# Confirms a valid user.
		def valid_user
			unless (@user && @user.activated? && 
							@user.authenticated?(:reset, params[:id]))
        render json: {error: 'invalid or not activated user!'},
          status: 404
			end	
		end

		# Checks expiration of reset token.
		def check_expiration
			if @user.password_reset_expired?
        render json: {error: 'password reset token has expired, request a new one'},
          status: 404
			end
		end
end
