require_relative 'config/env'

Post.drop_table
Post.create_table

last_user = User.last

post = Post.new
post.title = "Mini Orm"
post.content = "Orm With CSV"
post.user = last_user
post.save

post = Post.new
post.title = "Mini Orm 1"
post.content = "Orm With CSV 1"
post.user = last_user
post.save

# user = post.user

# post2 = user.posts.new
# post2.title = "advance association"
# post2.content = "checking advance assoiation new and save methods"
# post2.save

# # puts Post.all.inspect

# user.posts.create(title: "advance association 1", content: "checking advance assoiation create method")
# p post
p Post.find_by_id(1)
