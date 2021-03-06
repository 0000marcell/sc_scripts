class User < ActiveRecord::Base
  #has_and_belongs_to_many :profiles
  #has_one :image
  #has_many :posts
	attr_accessor :token, :activation_token, :reset_token,
    :reset_url, :activation_url
	before_save :downcase_email
	before_create :create_activation_digest
	validates :name, presence: true, length: { maximum: 50 }
  validates :username, presence: true, length: { maximum: 50 },
                       uniqueness: { case_sensitive: false }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 },
										format: { with: VALID_EMAIL_REGEX },
										uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, presence: true, length: { minimum: 6  }, allow_nil: true

	def activate
		update_attribute(:activated,    true)
		update_attribute(:activated_at, Time.zone.now)
	end

	# Sends activation email.
	def send_activation_email
		Api::V1::UserMailer.account_activation(self).deliver_now
	end

  # Create activation url
  def create_activation_url(url)
    self.activation_url = "#{url}/#{email}/#{activation_token}"
  end

	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
			                                                  BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	# Returns a random token.
	def User.new_token
		SecureRandom.urlsafe_base64
	end
	
	# Remembers a user in the database for use in persistent sessions.
	def remember
		self.token = User.new_token
		update_attribute(:remember_token, token)
	end

	# Returns true if the given token matches the digest.
	#def authenticated?(remember_token)
		#return false if remember_digest.nil?
		#BCrypt::Password.new(remember_digest).is_password?(remember_token)
	#end

	# Sets the password reset atributes 
	def create_reset_digest
		self.reset_token = User.new_token
		update_attribute(:reset_digest,  User.digest(reset_token))
		update_attribute(:reset_sent_at, Time.zone.now)
	end

  def create_reset_url(url)
    self.reset_url = "#{url}/#{email}/#{reset_token}" 
  end

	#Returns true if a password reset has expired
	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end

	# Sends the password reset email .
	def send_password_reset_email
		Api::V1::UserMailer.password_reset(self).deliver_now
	end

  # Returns true if the given token matches the digest.
	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
	  return false if digest.nil?
	  BCrypt::Password.new(digest).is_password?(token)
	end
	
	# Forgets a user
	def forget
		update_attribute(:remember_token, nil)
	end

	private 

		def downcase_email
			self.email = email.downcase
		end	

		def create_activation_digest
			self.activation_token = User.new_token
			self.activation_digest = User.digest(activation_token)
		end
end
