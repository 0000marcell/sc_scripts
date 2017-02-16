module SessionsHelper
  def self.set_current_user(user)
    @user = user
  end

  def self.current_user
    @user
  end
end
