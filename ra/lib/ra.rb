require 'ra/version'
require 'colorize'

program :name, 'ra'
program :version, Ra::VERSION
program :description, 'ra utility program.'
helpers 'IO'

TEMP = File.dirname(__FILE__) + '/../templates'

command :new do
  syntax 'ra new <program name>'  
  description 'generates a default rails api program'
  action do |args, options|
    puts "generating rails program"
    run_cmd "rails new #{args[0]} --api"
    write_end "gem 'active_model_serializers', github: 'rails-api/active_model_serializers', tag: 'v0.10.0.rc4'", "./Gemfile"
    run_cmd "bundle"
    puts "command finished".colorize(:green)
  end
end

command "generate login" do
  syntax 'ra generate login'
  description 'generates a default rails api program'
  action do |args, options|
    puts "generating login funtionality"
    # installing doorkeeper
    run_cmd "echo ""gem 'doorkeeper'"
    run_cmd "bundle"
    run_cmd "rails g doorkeeper:install"
    copy "#{TEMP}/application_controller.rb",
         "./app/controllers/application_controller.rb"
    # creating sessions controller
    run_cmd "rails g controller api/v1/sessions"
    copy "#{TEMP}/sessions_controller.rb",
         "./app/controllers/api/v1/sessions_controller.rb"
    # creating user model
    run_cmd "rails g model user"
    copy "#{TEMP}/user_model.rb",
         "./app/models/user.rb"

    # user serializer
    run_cmd "rails g serializer user name username email" 
    copy "#{TEMP}/user_serializer.rb",
         "./app/serializers/user_serializer.rb"
  end
end
