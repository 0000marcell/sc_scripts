require 'bcrypt'

module CRYPT_helper
  include BCrypt
	def generate_pass
    str = (0...8).map { (65 + rand(26)).chr  }.join
    pass = Password.create(str)
	end
end
