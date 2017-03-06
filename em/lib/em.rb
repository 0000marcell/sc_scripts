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
    run_cmd "ember g route home/password-reset"
    run_cmd "ember g route password-reset --path ':email/:token'"
    run_cmd "ember g route users"
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
    copy "#{TEMP}/home-password-reset.js",
      "./app/routes/home/password-reset.js"
    copy "#{TEMP}/home-password-reset.hbs",
      "./app/templates/home/password-reset.hbs"
    copy "#{TEMP}/password-reset.js",
      "./app/routes/password-reset.js"
    copy "#{TEMP}/password-reset.hbs",
      "./app/templates/password-reset.hbs"
    #Components
    puts 'generating components'
    run_cmd "ember g component abstract-form"
    run_cmd "ember g component session-component"
    run_cmd "ember g component login-form"
    run_cmd "ember g acceptance-test login"
    run_cmd "ember g component password-reset-form"
    run_cmd "ember g acceptance-test password-reset-form"
    run_cmd "ember g component password-change-form"
    run_cmd "ember g acceptance-test password-change-form"

    puts "copying components"
    copy "#{TEMP}/abstract-form.js",
         "./app/components/abstract-form.js"
    copy "#{TEMP}/abstract-form.hbs",
         "./app/templates/components/abstract-form.hbs"
    copy "#{TEMP}/session-component.js",
         "./app/components/session-component.js"
    copy "#{TEMP}/session-component.hbs",
         "./app/templates/components/session-component.hbs"
    copy "#{TEMP}/login-form.hbs",
         "./app/templates/components/login-form.hbs"
    template "#{TEMP}/login-form-test.erb",
         "./tests/acceptance/login-test.js", binding
    copy "#{TEMP}/login-form.js",
         "./app/components/login-form.js"
    template "#{TEMP}/password-reset-form.erb",
             "./app/components/password-reset-form.js",
             binding
    copy "#{TEMP}/password-reset-form.hbs",
      "./app/templates/components/password-reset-form.hbs"
    template "#{TEMP}/password-change-form.erb",
             "./app/components/password-change-form.js",
             binding
    copy "#{TEMP}/password-change-form.hbs",
      "./app/templates/components/password-change-form.hbs"
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
    mkdir './app/serializers/'
    copy "#{TEMP}/ember-mirage-serializer.js",
         './app/serializers/application.js'

    run_cmd "ember install ember-cli-mirage"
    run_cmd "ember g mirage-factory user"
    run_cmd "ember g mirage-model user"
    run_cmd "ember g mirage-serializer application"
    puts 'copying mirage files...'
    copy "#{TEMP}/mirage-serializer.js",
         "./mirage/serializers/application.js"
    copy "#{TEMP}/mirage-route-handlers.js",
         "./mirage/route-handlers.js"
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
    run_cmd "ember d route home/password-reset"
    run_cmd "ember d route users"
    run_cmd "ember d route users/user"
    run_cmd "ember d route index"
    run_cmd "ember d route password-reset"

    #Serializers
    rm_dir './app/serializers'

    #Components
    puts 'destroying components'
    run_cmd "ember d component abstract-form"
    run_cmd "ember d component session-component"
    run_cmd "ember d component login-form"
    run_cmd "ember d acceptance-test login"
    run_cmd "ember d component password-reset-form"
    run_cmd "ember d acceptance-test password-reset-form"
    run_cmd "ember d component password-change-form"
    run_cmd "ember d acceptance-test password-change-form"

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

command "uninstall s3" do
  syntax 'uninstall s3'
  description 'uninstall s3'
  action do |args, options|
    run_cmd "npm --save-dev uninstall ember-cli-deploy" 
    run_cmd "npm --save-dev uninstall ember-cli-deploy-build" 
    run_cmd "npm --save-dev uninstall ember-cli-deploy-revision-data" 
    run_cmd "npm --save-dev uninstall ember-cli-deploy-display-revisions" 
    run_cmd "npm --save-dev uninstall ember-cli-deploy-gzip" 
    run_cmd "npm --save-dev uninstall ember-cli-deploy-s3-index" 
    run_cmd "npm --save-dev uninstall ember-cli-deploy-s3" 
    rm_file "./config/deploy.js" 
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


command "uninstall electron" do
  syntax 'em uninstall electron'
  description 'uninstall electron'
  action do |args, options|
    run_cmd "npm --save-dev uninstall ember-electron" 
  end
end

command "generate model" do
  syntax 'ex: em g model user name:string todos:has-many:todo'
  description 'create ember model and mirage model and factory'
  action do |args, options|
    model_name = args[0]
    # ember model
    puts "generating model-mirage #{model_name}"
    run_cmd "ember g model #{args.join(" ")}"
    # mirage model
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
          write_after ".extend({", "\t#{@prop}: #{@relationship}('#{@model}'),",
            "./mirage/models/#{model_name}.js"
        end
      end
    end
    # mirage factory
    puts "creating #{model_name} mirage factory ".colorize(:green)
    run_cmd "ember g mirage-factory #{model_name}"
    write_in ["Factory", "import"], ", faker",
            "./mirage/factories/#{model_name}.js"
    args.each do |arg|
      if arg != model_name and arg !~ /has-many/ and 
                            arg !~ /belongs-to/
        arg = arg.split(':')[0]
        str = "\t#{arg}(){ return faker.lorem.word(); }," 
        write_after ".extend({", str,
            "./mirage/factories/#{model_name}.js"
      end
    end
    if !in_file? "this.namespace", "./mirage/config.js"
      write_after "default function()", "\tthis.namespace = '/api/v1';",
            "./mirage/config.js"
    end
    if !in_file? "this.get('/#{pluralize(model_name)}');", "./mirage/config.js"
      puts "creating route handlers in mirage config".colorize(:green)
      if !in_file? "import routeHandler", "./mirage/config.js"
        write_start "import routeHandler from './route-handlers';",
                    "./mirage/config.js"
      end
      write_after "this.namespace", "\tthis.get('/#{pluralize(model_name)}');",
              "./mirage/config.js"
      write_after "this.namespace", "\tthis.get('/#{pluralize(model_name)}/:id');",
            "./mirage/config.js"
      str = 
      <<~HEREDOC
        \tthis.patch('/#{pluralize(model_name)}/:id', (schema, request) => {
        \t\treturn routeHandler.put(schema, request); 
        \t});
      HEREDOC
      write_after "this.namespace", str,
            "./mirage/config.js"
      str = 
      <<~HEREDOC
        \tthis.post('/#{pluralize(model_name)}', (schema, request) => {
        \t\treturn routeHandler.put(schema, request); 
        \t});
      HEREDOC
      write_after "this.namespace", str,
            "./mirage/config.js"
      write_after "this.namespace", "\tthis.del('/#{pluralize(model_name)}/:id');",
            "./mirage/config.js"
      write_after "this.namespace", "\t// --#{model_name}",
            "./mirage/config.js"
    end
    puts <<~HEREDOC
      OM:
        you need to change the owner ember and mirage
        and create the relation on default.js e.g
        user.taks = tasks;
        user.save();
      OO:
        you need to change the owner ember and mirage
        and create the relation on default.js e.g 
        user.task = task;
        task.user = user;
        user.save();
        task.save();
      MM:
        you need to change the owner
        you need to point to the join model in mirage!,
        you also need to create the join model, and make the relationships on default.js 
        e.g server.create('user-tag', {userId: 1, tagId: 1});
    HEREDOC
  end
end

command "destroy model" do
  syntax 'ex: em d model user'
  description 'ex: em d model user'
  action do |args, options|
    model_name = args[0]
    run_cmd "ember d model #{model_name}"
    run_cmd "ember d mirage-model #{model_name}"
    run_cmd "ember d mirage-factory #{model_name}"
    rm_string "this.get('/#{pluralize(model_name)}');",
              "./mirage/config.js"
    rm_string "this.get('/#{pluralize(model_name)}/:id')",
            "./mirage/config.js"
    rm_block "this.post('/#{pluralize(model_name)}'",
              "});", "./mirage/config.js"
    rm_block "this.patch('/#{pluralize(model_name)}/:id'",
              "});", "./mirage/config.js"
    rm_string "this.del('/#{pluralize(model_name)}/:id')",
            "./mirage/config.js"
    rm_string "// --#{model_name}",
              "./mirage/config.js"
  end
end

command "generate join-model" do
  syntax 'ex: em generate join-model user-tag user tag'
  description 'ex: em generate join-model user-tag user tag'
  action do |args, options|
    model_name = args[0]
    puts "generate mirage model".colorize(:green)
    run_cmd "ember g mirage-model #{model_name}"
    copy "#{TEMP}/mirage-model.js",
         "./mirage/models/#{model_name}.js"
    str = "\t#{args[1]}: belongsTo(),\n\t#{args[2]}: belongsTo()"
    write_after ".extend({", str,
            "./mirage/models/#{model_name}.js"
    write_in ["Model", "import"], ", belongsTo", 
              "./mirage/models/#{model_name}.js"
  end
end

command "destroy join-model" do
  syntax 'ex: em destroy join-model <user-tag>'
  description 'ex: em destroy join-model <user-tag>'
  action do |args, options|
    run_cmd "ember d mirage-model #{args[0]}"
  end
end

command "generate form" do
  syntax 'em generate form <name> input:name input:username'
  description 'e.g: em generate form user input:name input:username'
  action do |args, options|
    file = File.read('./package.json')
    @app_name = JSON.parse(file)['name']
    @form_name = args[0]  
    run_cmd "ember g component #{@form_name}-form"
    run_cmd "ember g acceptance-test #{@form_name}-form"
    copy "#{TEMP}/form.js",
         "./app/components/#{@form_name}-form.js"
    copy "#{TEMP}/form.hbs",
         "./app/templates/components/#{@form_name}-form.hbs"
    template "#{TEMP}/form-acceptance-test.erb",
         "./tests/acceptance/#{@form_name}-form-test.js", binding
    args.reverse.each do |arg|
      if arg =~ /input/  
        puts "inserting inputs".colorize(:green)
        prop_name = arg.split(':')[1]
        str = <<~HEREDOC
          \t{{input id='test-#{prop_name}-form' 
            \t\tvalue=model.#{prop_name}
            \t\ttype="text" placeholder="#{prop_name}"}}
        HEREDOC
        write_after "#abstract-form", str,
          "./app/templates/components/#{@form_name}-form.hbs"
      end
      if arg =~ /select/
        puts "inserting select".colorize(:green)
        prop_name = arg.split(':')[1]
        str = <<~HEREDOC
          \t{{ember-selectize id='test-#{prop_name}-form' content=model.#{prop_name}
            \t\toptionValuePath="content.id" optionLabelPath="content.name" 
            \t\tselection=selected#{prop_name} multiple= placeholder="" }}  
        HEREDOC
        write_after "#abstract-form", str,
          "./app/templates/components/#{@form_name}-form.hbs"
      end
    end
  end
end

command "destroy form" do
  syntax 'em destroy form <name>'
  description 'e.g: em destroy form user'
  action do |args, options|
    name = args[0]  
    run_cmd "ember d component #{name}-form"
    run_cmd "ember d acceptance-test #{name}-form"
  end
end

command "info" do
  syntax 'em info <name>'
  description 'e.g em info'
  action do |args, options|
    puts `tree app/#{args[0]}` 
  end
end

command "generate crud-route" do
  syntax 'e.g em generate crud-route users/user todo'
  description 'e.g generate crud-route users/user todo'
  action do |args, options|
    puts "creating crud routes #{args[0]} #{args[1]}".colorize(:green)
    prefix   = args[0]
    model_p  = pluralize(args[1])
    @model_s  = singularize(args[1]) 
    run_cmd "ember g route #{prefix}/#{model_p}" 
    run_cmd "ember g route #{prefix}/#{model_p}/new"
    run_cmd "ember g route #{prefix}/#{model_p}/index"
    run_cmd "ember g route #{prefix}/#{model_p}/#{@model_s} --path :id"
    run_cmd "ember g route #{prefix}/#{model_p}/#{@model_s}/index"
    run_cmd "ember g route #{prefix}/#{model_p}/#{@model_s}/edit"
    puts "copying index route".colorize(:green)
    template "#{TEMP}/crud-route-index.erb",
      "./app/routes/#{prefix}/#{model_p}/#{@model_s}.js", binding
    puts "routes generated!".colorize(:green)
  end
end

command "destroy crud-route" do
  syntax 'e.g em destroy crud-route users/user todo'
  description 'e.g em destroy crud-route users/user todo'
  action do |args, options|
    puts "destroying crud routes #{args[0]} #{args[1]}".colorize(:green)
    prefix  = args[0]
    model_p = pluralize(args[1])
    model_s = singularize(args[1])
    run_cmd "ember d route #{prefix}/#{model_p}"
    run_cmd "ember d route #{prefix}/#{model_p}/new"
    run_cmd "ember d route #{prefix}/#{model_p}/index"
    run_cmd "ember d route #{prefix}/#{model_p}/#{model_s}"
    run_cmd "ember d route #{prefix}/#{model_p}/#{model_s}/index"
    run_cmd "ember d route #{prefix}/#{model_p}/#{model_s}/edit"
    puts "route #{prefix}/#{model_s} removed".colorize(:green)
  end
end

command "generate ws-component" do
  syntax 'ra generate ws-component chat-comp'
  description 'generates a component with ws connections'
  action do |args, options|
    @comp = args[0] 
    run_cmd "ember generate component #{@comp}"
    copy "#{TEMP}/ws-comp.js",
      "app/components/#{@comp}.js"
  end
end
