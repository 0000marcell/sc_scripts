# REF: 0
require 'json'
require 'em/version'
require 'byebug'

program :name, 'em'
program :version, Em::VERSION
program :description, 'generator for ember'
helpers 'IO', 'STR'

TEMP = File.dirname(__FILE__) + '/../templates'

command :new do
  syntax 'em new <program name>'  
  description 'generates a default ember program'
  action do |args, options|
    # return if is_not_intalled?('ember')
    dir_path = "#{File.expand_path('./')}/#{args[0]}"
    run_cmd "ember new #{args[0]} --skip-npm --skip-bower --skip-git --directory #{dir_path}"
    copy_dir "#{TEMP}/node_modules/",
         "./#{args[0]}/node_modules/"
    copy_dir "#{TEMP}/bower_components/",
         "./#{args[0]}/bower_components/"
    puts "command finished".colorize(:green)
  end
end 

command :materialize do
  syntax 'em materialize'
  description 'install ember materialize and creates a lading page'
  action do |args, options|
    run_cmd "ember install 'mike-north/ember-cli-materialize#v1'"
    run_cmd "ember generate ember-cli-materialize"
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
    run_cmd "ember g route home/login"
    run_cmd "ember g route home/signup"
    run_cmd "ember g route users/user --path ':user_username'"
    run_cmd "ember g route index"
    puts 'copying routes'
    copy "#{TEMP}/user.hbs",
         "./app/templates/users/user.hbs"
    copy "#{TEMP}/user.js",
         "./app/routes/users/user.js"
    copy "#{TEMP}/login.js",
         "./app/routes/home/login.js"
    copy "#{TEMP}/login.hbs",
         "./app/templates/home/login.hbs"
    copy "#{TEMP}/signup.js",
         "./app/routes/home/signup.js"
    copy "#{TEMP}/signup.hbs",
         "./app/templates/home/signup.hbs"
    copy "#{TEMP}/index.js",
         "./app/routes/index.js"
    #Components
    puts 'generating components'
    run_cmd "ember g component abstract-form"
    run_cmd "ember g component session-component"
    puts "copying components"
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
    run_cmd "ember g model user name:string email:string username:string password:string"

    #Services
    puts 'generating services'
    run_cmd "ember g service session"
    puts 'copying services'
    copy "#{TEMP}/service-session.js",
         "./app/services/session.js"

    #Adapters
    puts 'generating adapters'
    run_cmd "ember g adapter application"
    puts 'copying adapters'
    template "#{TEMP}/application-adapter.erb",
         "./app/adapters/application.js", binding

    #dependencies
    puts 'installing dependencies'
    run_cmd "ember install ember-simple-auth"
    mkdir './app/authenticators'
    template "#{TEMP}/authenticator-oauth2.erb",
         "./app/authenticators/oauth2.js", binding
    mkdir './app/authorizers/'
    copy "#{TEMP}/authorizer-oauth2.js",
         "./app/authorizers/oauth2.js"      

    run_cmd "ember install ember-cli-mirage"
    run_cmd "ember g mirage-factory user"
    run_cmd "ember g mirage-model user"
    puts 'copying mirage files...'
    copy "#{TEMP}/mirage-factory-user.js",
         "./mirage/factories/user.js" 
    copy "#{TEMP}/mirage-models-user.js",
         "./mirage/models/user.js"
    copy "#{TEMP}/mirage-scenarios-default.js",
         "./mirage/scenarios/default.js"
    copy "#{TEMP}/mirage-config.js",
         "./mirage/config.js"
    run_cmd "ember install ember-route-action-helper"

    # config enviroments
    puts 'copying config environment'
    template "#{TEMP}/environment.erb",
         "./config/environment.js", binding 
    puts "command finished".colorize(:green)
  end
end

command "destroy login" do
  syntax 'em destroy login'
  description 'destroys login page and logic'
  action do |args, options|
    puts 'destroy login'
    #Routes
    puts 'destroying routes'
    run_cmd "ember d route home/login"
    run_cmd "ember d route home/signup"
    run_cmd "ember d route users/user"

    #Components
    puts 'destroying components'
    run_cmd "ember d component abstract-form"
    run_cmd "ember d component session-component"

    #Model
    puts 'destroying models'
    run_cmd "ember d model user"

    #Services
    puts 'destroying services'
    run_cmd "ember d service session"

    #Adapters
    puts 'destroying adapters'
    run_cmd "ember d adapter application"

    #dependencies
    puts 'removing dependencies'
    run_cmd "npm uninstall --save-dev ember-simple-auth"
    rm_dir './app/authenticators'
    rm_dir './app/authorizers/'
    
    run_cmd "npm uninstall --save-dev ember-cli-mirage"
    rm_dir './mirage'

    run_cmd "npm uninstall --save-dev ember-route-action-helper"
  end
end

command "install s3 deployment" do
  syntax 'em deploy s3 <bucket name>'
  description 'install tooling for s3 deployment'
  action do |args, options|
    @bucket_name = args[0]
    # installing pluggins
    puts 'installing pluggins'
    puts 'installing neccessary plugins'
    run_cmd "ember install ember-cli-deploy"
    run_cmd "ember install ember-cli-deploy-build"
    run_cmd "ember install ember-cli-deploy-revision-data"
    run_cmd "ember install ember-cli-deploy-display-revisions"
    run_cmd "ember install ember-cli-deploy-gzip"
    run_cmd "ember install ember-cli-deploy-s3-index"
    run_cmd "ember install ember-cli-deploy-s3"
    # coping files
    puts "coping files deployment bucket: #{@bucket_name}"
    template "#{TEMP}/deploy.erb",
         "./config/deploy.js", binding
  end
end

command "deploy s3" do
  syntax 'em deploy s3'
  description 'deploy current project to s3 bucket'
  action do |args, options|
    puts 'deploying to s3, make sure you have commited your changes!'
    run_cmd "ember deploy production --verbose --activate=true"
  end
end

command "install electron" do
  syntax 'em install electron'
  description 'install and configure electron'
  action do |args, options|
    puts 'Installing ember-electron'
    run_cmd "ember install ember-electron"
  end
end

command "generate model" do
  syntax 'ex: em g model user name:string todos:has-many:todo'
  description 'create ember model and mirage model and factory'
  action do |args, options|
    model_name = args[0]
    puts "generating model-mirage #{model_name}"
    run_cmd "ember g model #{args.join(" ")}"
    puts "generate mirage model".colorize(:green)
    copy "#{TEMP}/mirage-model.js",
         "./mirage/models/#{model_name}.js"
    if args.grep /has-many/ or args.grep /belongs-to/
      args.each do |arg|
        if arg =~ /has-many/ or arg =~ /belongs-to/ 
          string = arg.split(':')
          @prop = string[0]
          @relationship = camelize(string[1])
          @model = string[2]
          if !in_file? @relationship, "./mirage/models/#{model_name}.js"
            write_in ["Model", "import"], ", #{@relationship}", 
              "./mirage/models/#{model_name}.js"
          end
          write_after ".extend({", "\t#{@prop}: #{@relationship}(#{@model})",
            "./mirage/models/#{model_name}.js"
        end
      end
    end
  end
end

command "destroy model" do
  syntax 'ex: em d model user'
  description 'ex: em d model user'
  action do |args, options|
    run_cmd "ember d model #{args[0]}"
    run_cmd "ember d mirage-model #{args[0]}"
  end
end
