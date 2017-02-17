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
    run_cmd "rails new #{args[0]} --api --skip-bundle"
    cd_in args[0]
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
    write_end "gem 'doorkeeper'", "./Gemfile"
    run_cmd "bundle"
    run_cmd "rails g doorkeeper:install"
    run_cmd "rails g doorkeeper:migration"
    # creating sessions controller
    run_cmd "rails g controller api/v1/sessions"
    copy "#{TEMP}/sessions_controller.rb",
         "./app/controllers/api/v1/sessions_controller.rb"

    # creating session controller test
    copy "#{TEMP}/sessions_controller_test.rb",
         "./test/controllers/api/v1/sessions_controller_test.rb"
    
    # creating sessions helper
    run_cmd "rails g helper sessions"
    copy "#{TEMP}/sessions_helper.rb",
         "./app/helpers/sessions_helper.rb"
    # creating user model
    user_args = 'name:string username:string email:string password_digest:string admin:boolean ' +
      'activated:boolean activation_digest:string reset_digest:string ' + 
      'activated_at:datetime reset_sent_at:datetime'
    run_cmd "rails g model user #{user_args}"
    copy "#{TEMP}/user_model.rb",
         "./app/models/user.rb"

    copy "#{TEMP}/users.yml",
         "./test/fixtures/users.yml"

    # user serializer
    run_cmd "rails g serializer user name username email" 
    copy "#{TEMP}/user_serializer.rb",
         "./app/serializers/user_serializer.rb"

    # creating mailer
    puts "creating application mailer"
    run_cmd "rails g mailer application"
    copy "#{TEMP}/application_mailer.rb",
         "./app/mailers/application_mailer.rb"

    # creating user mailer
    puts "creating user mailer"
    run_cmd "rails g mailer api/v1/user"
    copy "#{TEMP}/user_mailer.rb",
         "./app/mailers/api/v1/user_mailer.rb"

    # insert api/v1/login route
    if !in_file? "namespace :api",
      "./config/routes.rb"
      after_id = "use_doorkeeper"
      str = <<~HEREDOC
        \tnamespace :api do
          \t\tnamespace :v1 do
            \t\t\tpost '/login', to: 'sessions#create'
          \t\tend
        \tend
      HEREDOC
    else
      after_id = "namespace :v1"
      str = "\t\t\tpost '/login', to: 'sessions#create'"
    end
    write_after after_id, str,
      "./config/routes.rb"

    #running migrations
    run_cmd "rails db:migrate"
  end
end

command "destroy login" do
  syntax 'ra destroy login'
  description 'removes default rails api program'
  action do |args, options|
    # removing doorkeeper
    rm_file "./config/initializers/doorkeeper.rb"
    rm_string "use_doorkeeper", "./config/routes.rb"
    rm_string "post '/login', to: 'sessions#create'",
              "./config/routes.rb"
    rm_string "'doorkeeper'", './Gemfile' 
    run_cmd "bundle"
    run_cmd "rails d doorkeeper:install"
    # removing session controller
    run_cmd "rails d controller api/v1/sessions"
    # removing session helper
    run_cmd "rails d helper sessions"
    # removing user model
    run_cmd "rails d model user"
    # removing user serializer
    run_cmd "rails d serializer user name username email" 
    # removing mailer
    run_cmd "rails d mailer application"
    # removing user mailer
    run_cmd "rails d mailer api/v1/user"
  end
end
