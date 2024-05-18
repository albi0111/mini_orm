require_relative 'config/env'

User.drop_table
User.create_table
# if you want to clear the existing data and add new ones then uncooment the above lines

5.times do |index|
  new_user = User.new
  new_user.name = "John #{index} Deo"
  new_user.email = "john#{index}@example.com"
  new_user.save
  puts "User: John #{index} Deo Created"
end
