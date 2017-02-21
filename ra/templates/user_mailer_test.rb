require 'test_helper'

class Api::V1::UserMailerTest < ActionMailer::TestCase
  def setup
		@user = users(:root)
	end

	test "account_activation" do
		@user.activation_token = User.new_token
		mail = Api::V1::UserMailer.account_activation(@user).deliver_now
		assert_not ActionMailer::Base.deliveries.empty?
		assert_equal "Account activation", mail.subject
		assert_equal ["0000marcell@gmail.com"], mail.to
		assert_equal ["0000test@gmail.com"], mail.from
		assert_match "Hi", mail.body.encoded
	end

	test "password_reset" do
		@user.activated = true
		@user.reset_token = User.new_token
	  mail = Api::V1::UserMailer.password_reset(@user).deliver_now
		assert_not ActionMailer::Base.deliveries.empty?
		assert_equal "Password reset", mail.subject
		assert_equal ["0000marcell@gmail.com"], mail.to
		assert_equal ["0000test@gmail.com"], mail.from
		assert_match @user.name, mail.body.encoded
	end
end
