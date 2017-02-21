require 'test_helper'

class Api::V1::PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:root)
  end

  test "creates a reset token" do
    post '/api/v1/password_resets', params: {user: {email: @user.email}}     
    assert_response :success
    response_json = JSON.parse(response.body)
    assert_equal response_json['name'], @user.name 
    assert_equal response_json['id'], @user.id
    assert_equal response_json['email'], @user.email
  end

  test "don't update password if the reset token is invalid" do
    patch '/api/v1/password_resets/asfasdf', 
      params: {user: {email: @user.email, password: 'testing password!'}}
    response_json = JSON.parse(response.body)
    assert_equal response_json['error'], 'invalid or not activated user!' 
  end

  test "don't update password if the token is expired" do
    reset_token = "FSx1BRmheoH-uYqVxVlWzA"
    patch "/api/v1/password_resets/#{reset_token}", 
      params: {user: {email: @user.email, password: 'testing password!'}}
    response_json = JSON.parse(response.body)
    assert_equal response_json['error'], 
      'password reset token has expired, request a new one'
  end

  test "updates a password" do
    #path 'api/v1/password_reset', params: 
  end
end
