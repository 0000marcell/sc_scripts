arg = "todos:has-many:todo"
puts arg !~ /has-many/
if arg !~ /has-many/ and arg !~ /belongs-to/
  puts "ok"
else
  puts "not ok"
end
