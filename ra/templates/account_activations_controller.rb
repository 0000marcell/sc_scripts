class AccountActivationsController < ApplicationController
  def edit
		user = User.find_by(email: params[:email])
		if user && !user.activated? && user.authenticated?(:activation, params[:id])
			user.activate
			user.update_attribute(:activated, true)
			user.update_attribute(:activated_at, Time.zone.now)
			msg = 'User authenticated, you can login on the app!'
      render json: {msg: msg}
    elsif user && user.activated?
      msg = 'User already authenticated, you can login on the app!'
      render json: {error_description: msg}, status: 422
    else
      msg = <<~HEREDOC
        This activation link is not working anymore,
        Signup again to receive another one.
      HEREDOC
      render json: {error_description: msg}, status: 422
		end
	end
end
