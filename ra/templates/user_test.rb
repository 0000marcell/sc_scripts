require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:root)  
  end

  test "create user url" do
    @user.create_reset_digest
    @user.create_reset_url('asdf')
    puts @user.reset_url
    assert_equal @user.reset_url, 
      "asdf/0000marcell@gmail.com/#{@user.reset_token}" 
  end
end
