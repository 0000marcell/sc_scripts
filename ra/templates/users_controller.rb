class Api::V1::UsersController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:index, :show, :edit, :destroy, :update]

	def index
    if params[:username]
      @data = User.find_by(username: params[:username])
    else
		  @data = User.all
    end
		render json: @data
	end

	def show
		@user = User.find(params[:id])
		render json: @user
	end

	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params) 
		if @user.save
      @user.create_activation_url("#{request.headers['origin']}/account-activation")
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
      params.require(:data).require(:attributes).permit(:name, 
         :username,
         :email,
         :password,
         :password_confirmation)
		end

    def update_params
      params.permit(:name, :username)
    end
end
