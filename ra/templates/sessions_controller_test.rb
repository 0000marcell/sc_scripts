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
    assert_equal response_json['error_description'], 
      "User isn't activated, please verify your email to activate the user!"
  end

  test "tries to login with wrong password" do
    post '/api/v1/login', params: {username: @user.email,
                                  password: 'wrong'} 
    assert_response 422
    response_json = JSON.parse(response.body)
    assert_equal response_json['error_description'], 
      "Wrong password!"
  end

  test "tries to login with wrong email" do
    post '/api/v1/login', params: {username: 'something',
                                  password: '123456'} 
    assert_response 422
    response_json = JSON.parse(response.body)
    assert_equal response_json['error_description'], 
      "This user doesn't exist!"
  end

  test "gets current loged in user" do
    post '/api/v1/login', params: {username: @user.email,
                                  password: '123456'} 
    assert_response :success   
    get '/api/v1/current_user'
    assert_response :success   
    response_json = JSON.parse(response.body)
    assert_equal response_json['username'], '____marcell' 
  end
end
