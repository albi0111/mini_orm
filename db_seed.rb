require_relative 'config/env'

User.drop_table
User.create_table
# if you want to clear the existing data and add new ones then uncooment the above lines

5.times do |index|
  User.create(name: "John #{index} Deo", email:"john#{index}@example.com")
  puts "User: John #{index} Deo Created"
end
