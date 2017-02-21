require 'test_helper'

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @users = [users(:root), users(:johndoe)]
    post '/api/v1/login', params: {username: @users[0].email,
                                  password: '123456'}
    response_json = JSON.parse(response.body)
    @header = {:access_token => response_json["access_token"]}
  end

  test "get all the users" do
    get "/api/v1/users", params: @header  
    response_json = JSON.parse(response.body)
    assert_response :success
    assert_equal response_json.length, 2 
  end

  test "block access when not authorized" do
    get "/api/v1/users"
    assert_response 401
    response_json = JSON.parse(response.body)
    assert_equal response_json['error'], "Not authorized!"
  end
  
  test "get specific user" do
    get "/api/v1/users/1", params: @header
    assert_response :success
    response_json = JSON.parse(response.body)
    assert_equal "Marcell Monteiro Cruz", response_json['name']
  end

  test "create new user" do
    post "/api/v1/users", params: {name: "joao da silva", username: "____joao",
      email: "joao@gmail.com", password: "123456", password_confirmation: "123456"}
    response_json = JSON.parse(response.body)
    assert_equal response_json['username'], '____joao'
  end
end
