require 'test_helper'

class AccountActivationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:johndoe)
    @activated_user = users(:root)
  end

  test "activates a user" do
    activation_token = "FSx1BRmheoH-uYqVxVlWzA"
    get "/account_activations/#{activation_token}/edit", params: { email: @user.email }   
    assert_response :success
    response_json = JSON.parse(response.body)
    assert_equal response_json['msg'], 
      'User authenticated, you can login on the app!' 
  end

  test "do not activate a user when the activation_token is wrong" do
    activation_token = "12FSx1BRmheoH-uYqVxVlWzA"
    get "/account_activations/#{activation_token}/edit", params: { email: @user.email }   
    assert_response 422
    response_json = JSON.parse(response.body)
    msg = <<~HEREDOC
        This activation link is not working anymore,
        Signup again to receive another one.
      HEREDOC
    assert_equal response_json['error_description'], 
      msg
  end

  test "user is already activated" do
    activation_token = "FSx1BRmheoH-uYqVxVlWzA"
    get "/account_activations/#{activation_token}/edit", params: { email: @activated_user.email }   
    assert_response 422
    response_json = JSON.parse(response.body)
    assert_equal response_json['error_description'], 
      'User already authenticated, you can login on the app!'
  end
end
