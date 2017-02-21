class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :username, :email, 
    :reset_token, :activation_token
end
