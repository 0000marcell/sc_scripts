# REF: 0
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
		#Routes
		puts 'generating routes'
		`ember g route home/login`
		`ember g route home/signup`
		`ember g route users/user`
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
		`ember g component abstract-form`
		`ember g component session-component`
		puts 'copying components'
		copy "#{TEMP}/abstract-form.js",
				 "./app/components/abstract-form.js"
		copy "#{TEMP}/abstract-form.hbs",
				 "./app/templates/components/abstract-form.js"
		copy "#{TEMP}/session-component.js",
				 "./app/components/session-component.js"
		copy "#{TEMP}/session-component.hbs",
				 "./app/templates/components/session-component.js"

		#Model
		puts 'generating models'
		`ember g model user name:string email:string username:string password:string`

		#Services
		puts 'generating services'
		`ember g service session`
		puts 'copying services'
		copy "#{TEMP}/service-session.js",
				 "./app/services/session.js"

		#Adapters
		puts 'generating adapters'
		`ember g adater application`
		puts 'copying adapters'
		copy "#{TEMP}/applicaion-adapter.js",
				 "./app/adapters/application.js"
	end
end

command "destroy login" do
	syntax 'em generate login'
	description 'destroys login page and logic'
	action do |args, options|
		puts 'destroy login'
		puts `ember d route login`
		puts `ember d route signup`
		puts `ember d route users/user`
		puts `ember d controller login`
		puts `ember d controller signup`
		puts `ember d component session-component`
		puts `npm uninstall --save-dev ember-simple-auth`
	end
end
