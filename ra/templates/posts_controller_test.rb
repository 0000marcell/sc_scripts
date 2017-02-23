require 'test_helper'

class Api::V1::PostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @users = [users(:root), users(:johndoe)]
    post '/api/v1/login', params: {username: @users[0].email,
                                  password: '123456'}
    response_json = JSON.parse(response.body)
    @header = {Authorization: "Bearer #{response_json['access_token']}"}
  end

  test "get all the posts" do
    get "/api/v1/posts", headers: @header  
    response_json = JSON.parse(response.body)
    assert_response :success
    assert_equal 2, response_json['data'].length
  end

  test "block access when not authorized" do
    get "/api/v1/posts"
    assert_response 401
    response_json = JSON.parse(response.body)
    assert_equal response_json['error'], "Not authorized!"
  end
  
  test "get specific post" do
    get "/api/v1/posts/1", headers: @header
    assert_response :success
    response_json = JSON.parse(response.body)
    assert_equal 'title 1', 
      response_json['data']['attributes']['title']
  end

  test "create new post" do
    post "/api/v1/posts", 
      params: { todo: { title: 'new title', content: 'new content'  }}, 
      headers: @header
    response_json = JSON.parse(response.body)
    assert_equal 'new title', response_json['data']['attributes']['title']
  end
  
  test "edit post" do
    patch "/api/v1/posts/1", 
      params: { todo: { title: 'edited title'} }, headers: @header
    get "/api/v1/posts/1", headers: @header
    assert_response :success
    response_json = JSON.parse(response.body)
    assert_equal 'edited title', 
      response_json['data']['attributes']['title']
  end

  test "delete post" do
    delete "/api/v1/posts/1", headers: @header
    assert_response :success
  end
end
