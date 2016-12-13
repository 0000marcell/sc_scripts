# REF: 0
require 'json'
require 'rainbow'
require 'em/version'
require 'byebug'

program :name, 'em'
program :version, Em::VERSION
program :description, 'generator for ember'
helpers 'IO'

TEMP = File.dirname(__FILE__) + '/../templates'

command :new do
  syntax 'em new <program name>'  
  description 'generates a default ember program'
  action do |args, options|
    # return if is_not_intalled?('ember')
    dir_path = "#{File.expand_path('./')}/#{args[0]}"
    result = `ember new #{args[0]} --skip-npm --skip-bower --skip-git --directory #{dir_path}`
    copy_dir "#{TEMP}/node_modules/",
         "./#{args[0]}/node_modules/"
    copy_dir "#{TEMP}/bower_components/",
         "./#{args[0]}/bower_components/"
    say Rainbow(result).magenta
  end
end 

command :materialize do
  syntax 'em materialize'
  description 'install ember materialize and creates a lading page'
  action do |args, options|
    puts `ember install "mike-north/ember-cli-materialize#v1"`
    puts `ember generate ember-cli-materialize`
  end
end

command "generate login" do
  syntax 'em generate login'
  description 'generates login page and logic'
  action do |args, options|
    puts 'generate login'
    puts 'getting project name'
    file = File.read('./package.json')
    @app_name = JSON.parse(file)['name']
    puts "app name is #{@app_name}"
    #Routes
    puts 'generating routes'
    puts `ember g route home/login`
    puts `ember g route home/signup`
    puts `ember g route users/user`
    puts 'copying routes'
    copy "#{TEMP}/login.js",
         "./app/routes/home/login.js"
    copy "#{TEMP}/login.hbs",
         "./app/templates/home/login.hbs"
    copy "#{TEMP}/signup.js",
         "./app/routes/home/signup.js"
    copy "#{TEMP}/signup.hbs",
         "./app/templates/home/signup.hbs"

    #Components
    puts 'generating components'
    puts `ember g component abstract-form`
    puts `ember g component session-component`
    puts 'copying components'
    copy "#{TEMP}/abstract-form.js",
         "./app/components/abstract-form.js"
    copy "#{TEMP}/abstract-form.hbs",
         "./app/templates/components/abstract-form.hbs"
    copy "#{TEMP}/session-component.js",
         "./app/components/session-component.js"
    copy "#{TEMP}/session-component.hbs",
         "./app/templates/components/session-component.hbs"

    #Model
    puts 'generating models'
    puts `ember g model user name:string email:string username:string password:string`

    #Services
    puts 'generating services'
    puts `ember g service session`
    puts 'copying services'
    copy "#{TEMP}/service-session.js",
         "./app/services/session.js"

    #Adapters
    puts 'generating adapters'
    puts `ember g adapter application`
    puts 'copying adapters'
    template "#{TEMP}/application-adapter.erb",
         "./app/adapters/application.js", binding

    #dependencies
    puts 'installing dependencies'
    puts `ember install ember-simple-auth`
    mkdir './app/authenticators'
    template "#{TEMP}/authenticator-oauth2.erb",
         "./app/authenticators/oauth2.js", binding
    mkdir './app/authorizers/'
    copy "#{TEMP}/authorizer-oauth2.js",
         "./app/authorizers/oauth2.js"      

    puts `ember install ember-cli-mirage`
    puts `ember g mirage-factory user`
    puts `ember g mirage-model user`
    puts 'copying mirage files...'
    copy "#{TEMP}/mirage-factory-user.js",
         "./mirage/factories/user.js" 
    copy "#{TEMP}/mirage-models-user.js",
         "./mirage/models/user.js"
    copy "#{TEMP}/mirage-scenarios-default.js",
         "./mirage/scenarios/default.js"
    copy "#{TEMP}/mirage-config.js",
         "./mirage/config.js"

    puts `ember install ember-route-action-helper`

    # config enviroments
    puts 'copying config environment'
    copy "#{TEMP}/enviroment.js",
         "./config/enviroment.js" 
  end
end

command "destroy login" do
  syntax 'em destroy login'
  description 'destroys login page and logic'
  action do |args, options|
    puts 'destroy login'
    #Routes
    puts 'destroying routes'
    puts `ember d route home/login`
    puts `ember d route home/signup`
    puts `ember d route users/user`

    #Components
    puts 'destroying components'
    puts `ember d component abstract-form`
    puts `ember d component session-component`

    #Model
    puts 'destroying models'
    puts `ember d model user`

    #Services
    puts 'destroying services'
    puts `ember d service session`

    #Adapters
    puts 'destroying adapters'
    puts `ember d adapter application`

    #dependencies
    puts 'removing dependencies'
    puts `npm uninstall --save-dev ember-simple-auth`
    rm_dir './app/authenticators'
    rm_dir './app/authorizers/'
    
    puts `npm uninstall --save-dev ember-cli-mirage`
    rm_dir './mirage'

    puts `npm uninstall --save-dev ember-route-action-helper`
  end
end
