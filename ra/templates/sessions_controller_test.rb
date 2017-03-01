require 'test_helper'

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:root)
    @johndoe = users(:johndoe)
  end 

  test "logins an user" do
    post '/api/v1/login', params: {username: @user.email,
                                  password: '123456'} 
    assert_response :success
    response_json = JSON.parse(response.body)
    assert_equal response_json['token_type'], "bearer" 
    assert_equal response_json['user']['email'], "0000marcell@gmail.com" 
  end

  test "tries to login a unactivated user" do
    post '/api/v1/login', params: {username: @johndoe.email,
                                  password: '123456'} 
    assert_response 422
    response_json = JSON.parse(response.body)
    assert_equal response_json['errors'], 
      "User isn't activated, please verify your email to activate the user!"
  end

  test "tries to login with wrong password" do
    post '/api/v1/login', params: {username: @user.email,
                                  password: 'wrong'} 
    assert_response 422
    response_json = JSON.parse(response.body)
    assert_equal response_json['errors'], 
      "Wrong password!"
  end

  test "tries to login with wrong email" do
    post '/api/v1/login', params: {username: 'something',
                                  password: '123456'} 
    assert_response 422
    response_json = JSON.parse(response.body)
    assert_equal response_json['errors'], 
      "This user doesn't exist!"
  end

  test "change remember_token after login" do
    post '/api/v1/login', params: {username: @user.email,
                                  password: '123456'} 
    assert_response :success
    response_json = JSON.parse(response.body)
    assert_equal User.find(1).remember_token, response_json['remember_token']
  end
end
