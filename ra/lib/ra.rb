require 'ra/version'
require 'colorize'

program :name, 'ra'
program :version, Ra::VERSION
program :description, 'ra utility program.'
helpers 'IO', 'STR'

TEMP = File.dirname(__FILE__) + '/../templates'

command :new do
  syntax 'ra new <program name>'  
  description 'generates a default rails api program'
  action do |args, options|
    puts "generating rails program"
    run_cmd "rails new #{args[0]} --api --skip-bundle"
    cd_in args[0]
    write_end "gem 'active_model_serializers', github: 'rails-api/active_model_serializers', tag: 'v0.10.0.rc4'", "./Gemfile"
    # copying json_api initializer
    copy "#{TEMP}/json_api.rb", 
         "./config/initializers/json_api.rb"
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

    # copying session controller test
    copy "#{TEMP}/sessions_controller_test.rb",
         "./test/controllers/api/v1/sessions_controller_test.rb"
    
    # creating sessions helper
    run_cmd "rails g helper sessions"
    copy "#{TEMP}/sessions_helper.rb",
         "./app/helpers/sessions_helper.rb"
    
    # configuring action cable
    copy "#{TEMP}/connection.rb",
      "app/channels/application_cable/connection.rb"
    # creating action cable route
    str = "\tmatch '/websocket/:token', to: ActionCable.server, via: [:get, :post]"
    write_after "routes.draw", str,
      "config/routes.rb"

    # allowing all origins for actions cables
    str = "config.action_cable.disable_request_forgery_protection = true"
    write_after "application.configure", str, 
      "config/environments/development.rb"

    # creating user model
    user_args = 'name:string username:string email:string password_digest:string admin:boolean ' +
      'activated:boolean activation_digest:string reset_digest:string remember_token:string ' + 
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
    puts "creating user mailer".colorize(:green)
    run_cmd "rails g mailer api/v1/user"
    copy "#{TEMP}/user_mailer.rb",
         "./app/mailers/api/v1/user_mailer.rb"

    # copying user mailer test
    copy "#{TEMP}/user_mailer_test.rb",
      "./test/mailers/api/v1/user_mailer_test.rb"

    # copying mailers templates
    puts "copying mailer templates".colorize(:green)
    copy "#{TEMP}/account_activation.html.erb",
    "./app/views/api/v1/user_mailer/account_activation.html.erb"
    copy "#{TEMP}/account_activation.text.erb",
    "./app/views/api/v1/user_mailer/account_activation.text.erb"
    copy "#{TEMP}/password_reset.html.erb",
      "./app/views/api/v1/user_mailer/password_reset.html.erb"
    copy "#{TEMP}/password_reset.text.erb",
      "./app/views/api/v1/user_mailer/password_reset.text.erb"

    # insert api/v1/login route
    if !in_file? "namespace :api",
      "./config/routes.rb"
      after_id = "use_doorkeeper"
      str = <<~HEREDOC
        \tnamespace :api do
          \t\tnamespace :v1 do
            \t\t\tpost '/login', to: 'sessions#create'
            \t\t\tresources :password_resets,     only: [:new, :create, :edit, :update]
          \t\tend
        \tend
      HEREDOC
    else
      after_id = "namespace :v1"
      str = <<~HEREDOC
        \t\t\tpost '/login', to: 'sessions#create'
      HEREDOC
    end
    write_after after_id, str,
      "./config/routes.rb"

    write_after "use_doorkeeper", 
      "\tresources :account_activations, only: [:edit]",
      "./config/routes.rb"

    # Creating password reset controller
    puts "Creating password reset controller".colorize(:green)
    run_cmd "rails g controller api/v1/password_resets"

    # Copying password reset controller
    copy "#{TEMP}/password_resets_controller.rb",
         "./app/controllers/api/v1/password_resets_controller.rb"

    # Copying password reset controller test
    copy "#{TEMP}/password_resets_controller_test.rb",
         "./test/controllers/api/v1/password_resets_controller_test.rb"

    #Creating account activation controller
    puts "Creating account activation controller".colorize(:green)
    run_cmd "rails g controller account_activations"
     
    #Copying account activation controller
    copy "#{TEMP}/account_activations_controller.rb",
         "./app/controllers/account_activations_controller.rb"

    # Copying account activation test
    copy "#{TEMP}/account_activations_controller_test.rb",
      "./test/controllers/account_activations_controller_test.rb"

    # Insert mailer configuration 
    puts "Inserting mailer configuration".colorize(:green)
    # mailer options
    str = <<~HEREDOC
      \thost = '0.0.0.0:3000'
      \tconfig.action_mailer.default_url_options = { host: host    }
      \tconfig.action_mailer.raise_delivery_errors = true 
      \tconfig.action_mailer.perform_deliveries = true  
      \tconfig.action_mailer.default :charset => "utf-8"  
      \tconfig.action_mailer.delivery_method = :smtp
      \tconfig.action_mailer.smtp_settings = { domain: host }  
    HEREDOC
    after_id = "mailer"
    write_after after_id, str,
      "./config/environments/development.rb"
    write_after after_id, str,
      "./config/environments/production.rb"
    write_after after_id, str,
      "./config/environments/test.rb"
    str = <<~HEREDOC
      ActionMailer::Base.delivery_method = :smtp
      ActionMailer::Base.smtp_settings = {
        :user_name => ENV['SENDGRID_USERNAME'],
        :password =>  ENV['SENDGRID_PASSWORD'],
        :address => 'smtp.sendgrid.net',
        :port => 587,
        :authentication => :plain,
        :enable_starttls_auto => true
      }
    HEREDOC
    # writing not authorized error on application controller
    write_after "Rails.application.initialize", str,
      "./config/environment.rb" 
    if in_file? "private", 
      "./app/controllers/application_controller.rb"
      str = <<~HEREDOC
        \t\tdef doorkeeper_unauthorized_render_options(error: nil)
          \t\t{ json: { error: "Not authorized!" } }	
        \t\tend
      HEREDOC
    else
      str = <<~HEREDOC
        \tprivate  
        \t\tdef doorkeeper_unauthorized_render_options(error: nil)
          \t\t\t{ json: { error: "Not authorized!" } }	
        \t\tend
      HEREDOC
    end
    write_after "Application", str,
      "./app/controllers/application_controller.rb" 

    # creating users controller 
    puts "Creating users controller".colorize(:gren)
    run_cmd "rails g controller api/v1/user"
    # copying users controller
    copy "#{TEMP}/users_controller.rb",
      "app/controllers/api/v1/users_controller.rb"
    # copying users controller test
    copy "#{TEMP}/users_controller_test.rb",
      "test/controllers/api/v1/users_controller_test.rb"

    # inserting users controller routes
    puts "insert users routes".colorize(:green)
    write_after ":v1", "resources :users",
      "./config/routes.rb"

    #copying seeds for the db
    copy "#{TEMP}/seeds.rb",
      "db/seeds.rb"

    # copying cors configuration allowing any origin
    copy "#{TEMP}/cors.rb",
      "config/initializers/cors.rb"

    #running migrations
    run_cmd "rails db:migrate"
    # seeding the db
    run_cmd "rails db:seed"
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
    rm_string "post '/current_user'", 
      "./config/routes.rb"
    rm_string "resources :password_resets", 
      "./config/routes.rb"
    rm_string "'doorkeeper'", './Gemfile' 
    rm_string "resources :account_activations",
      "./config/routes.rb"
    run_cmd "bundle"
    run_cmd "rails d doorkeeper:install"
    # removing session controller
    run_cmd "rails d controller api/v1/sessions"
    # removing session helper
    run_cmd "rails d helper sessions"
    # removing user model
    run_cmd "rails d model user"
    # removing user serializer
    run_cmd "rails d serializer user" 
    # removing mailer
    run_cmd "rails d mailer application"
    # removing user mailer
    run_cmd "rails d mailer api/v1/user"
    rm_file "test/fixtures/users.yml"
    # removing controller password resets
    puts "removing controller password resets".colorize(:green)
    run_cmd "rails d controller api/v1/password_resets"
    # removing controller account_activations
    puts "removing controller account_activations".colorize(:green)
    run_cmd "rails d controller account_activations"
    # removing users controller    
    run_cmd "rails d controller api/v1/user"
    # removing user from routes
    rm_string "resources :users", "./config/routes.rb"
  end
end

command "generate model" do
  syntax 'ra generate model name:string user:references --rel OM'
  description  <<~HEREDOC
    e.g ra generate model name:string user:belongs-to --rel OM
    you dont need to use api/v1, it will be infered
    rel defaults to OM
  HEREDOC
  option '--rel STRING', String, 'OO OM and MM:user'
  action do |args, options|
    options.default rel: 'OM'
    if options.rel =~ /MM/
      model_a = args[0]
      model_b = options.rel.split(':')[1]
      if model_a < model_b 
        @model_1_s = model_a
        @model_2_s = model_b
      else
        @model_1_s = model_b
        @model_2_s = model_a
      end
      @model_s = @model_1_s
      @model_p = pluralize(@model_1_s)
      @model_p_c = @model_p.capitalize
      @model_s_c = @model_s.capitalize
      @model_1_p   = pluralize(@model_1_s)
      @model_1_p_c = @model_1_p.capitalize
      @model_2_p   = pluralize(@model_2_s)
      @model_2_p_c = @model_2_p.capitalize
      @rel = options.rel.split(':')[0]
      run_cmd <<~HEREDOC
        rails generate migration create_join_table_#{@model_1_p}_#{@model_2_p}
      HEREDOC
      file_name = find_file("create_join_table", "./db/migrate")
      template "#{TEMP}/join_model_migration.erb",
        "./db/migrate/#{file_name}", binding
      template "#{TEMP}/join_fixture.erb",
        "./test/fixtures/#{@model_1_p}_#{@model_2_p}.yml", binding
    else
      @model_s = singularize(args[0])
      @model_p = pluralize(@model_s)
      @model_p_c = @model_p.capitalize
      @model_s_c = @model_s.capitalize
      @rel = options.rel
    end
    @attr = args[1].split(':')[0]
    puts "generating model #{@model_s}".colorize(:green)
    run_cmd "rails g model #{args.join(" ")}"
    run_cmd "rails g serializer #{args.join(" ")}"  
    run_cmd "rails g controller api/v1/#{@model_p}"
    write_after ":v1 do", "\t\tresources :#{@model_p}",
      "config/routes.rb"
    
    template "#{TEMP}/controller_#{@rel}_test.erb",
      "./test/controllers/api/v1/#{@model_p}_controller_test.rb",
      binding
    template "#{TEMP}/controller_#{@rel}.erb",
      "./app/controllers/api/v1/#{@model_p}_controller.rb",
      binding
    run_cmd "rails db:migrate"
    puts <<~HEREDOC
      Now you need to alter the fixtures, include has_many etc ...
      rel on the other side of the relation on the model and serializer
      and finish writing the controller tests
      dont forget dependent: :destroy on the relationship 
      and to change the permit of the generated model
    HEREDOC
  end
end

command "destroy model" do
  syntax 'ra destroy model post'
  description 'ra destroy model post'
  action do |args, options|
    model_s = singularize(args[0])
    model_p = pluralize(model_s)
    puts "destroying model #{model_s}".colorize(:green)
    run_cmd "rails d model #{model_s}"
    run_cmd "rails d serializer #{model_s}"  
    run_cmd "rails d controller api/v1/#{model_p}"
    # removing resources from the routes
    rm_string "resources :#{model_p}",
      "./config/routes.rb"
    puts <<~HEREDOC
      model, serializer and controller removed
      now you need to removed the relationships on the 
      other models that used the removed model
    HEREDOC
  end
end

command "generate channel" do
  syntax 'ra generate channel messages'
  description 'ra generate channel messages'
  action do |args, options|
    @channel = pluralize(args[0])
    puts "generating channel #{@channel}".colorize(:green)
    run_cmd "rails generate channel #{@channel}"
    template "#{TEMP}/channel.erb",
      "app/channels/#{@channel}_channel.rb", binding
    puts "channel generated!".colorize(:magenta)
  end
end

command "destroy channel" do
  syntax 'ra destroy channel messages'
  description 'ra destroy channel messages'
  action do |args, options|
    puts "destroying #{args[0]} channel".colorize(:green)
    run_cmd "rails destroy channel #{args[0]}"
    puts "channel #{args[0]} was destroyed!"
  end
end
