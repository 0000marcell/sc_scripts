require 'pa/version'

FILE = File.dirname(__FILE__) + '/../../../pa.json'

program :name, 'pa'
program :version, Pa::VERSION
program :description, 'pa utility program.'
helpers 'IO', 'CRYPT'

command "generate" do
  syntax 'generate'
  description 'generate'
  action do |args, options|
    result = generate_pass 
    write_start result, FILE
  end
end

command "read" do
  syntax 'read'
  description 'read'
  action do |args, options|
    say read FILE
  end
end
