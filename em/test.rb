require 'colorize'

# the 2 ids the second one is just a safe item the string
# will be inserted after the first one
def write_in(ids, string, path, dup = false)
  puts "Trying to write in line after #{ids} the string #{string[0...8]} ... on the file #{path}".colorize(:magenta)
	lines = []
	File.open(path, 'r'){|f| lines = f.readlines }
  regexps = []
  ids.each { |id| regexps << Regexp.new(id) }
	new_lines = lines.inject([]) do |result, value|
    if value =~ regexps[0] and value =~ regexps[1]
      insert = true
      if !dup
        insert = value =~ Regexp.new(string) ? false : true
      end
      if insert
        index = value =~ regexps[0]
        value.insert(index + ids[0].length, 
                   string)
      else
        puts "The string to be inserted was already in the line".colorize(:red)
      end
    end
    result << value
  end
  File.open(path, 'w+'){|f| f.write(new_lines.join)}
end

write_in(['Model', 'import'], ', hasMany', "./user.js")
