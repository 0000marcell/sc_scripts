line = "this.post('/users').something"
start_regexp = Regexp.new(Regexp.escape("this.post('/users')"))
if line =~ start_regexp 
  puts "match"
end




