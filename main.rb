require_relative 'config/env'


# User.create_table

# user = User.new
# user.name = "John Doe test cb"
# user.email = "john@example.com"
# user.save

# puts User.all.map(&:name)

john1 = User.first
john1.update(name: 'john_updating_21', email: "john@example.com" )
puts john1.name
john1.delete
puts User.all.map(&:name)
