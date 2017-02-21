class Api::V1::UsersController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:index, :show, :edit, :destroy, :update]

	def index
		@users = User.all
		render json: @users
	end

	def show
		# work around for ember data
		if(params[:id].to_i != 0)
			@user = User.find(params[:id])
		else
			@user = User.find_by_username(params[:id])
		end	
		render json: @user
	end

	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params) 
		if @user.save
			@user.send_activation_email
			render json: @user 		
		else
			render json: @user.errors, status: 422
		end
	end

	def edit
		@user = User.find(params[:id])
	end

	def destroy
		User.find(params[:id]).destroy
		render json: {msg: 'user deleted'}
	end

	def update
		@user = User.find(params[:id])
		if @user.update_attributes(update_params)
			render json: @user
		else
			render json: @user.errors, status: 404
		end
	end

	private

		def user_params
			params.permit(:name, :username, :email, 
																	 :password, 
																	 :password_confirmation)
		end

    def update_params
      params.permit(:name, :username)
    end
end
