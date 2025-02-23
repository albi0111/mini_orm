require_relative 'config/env'

Post.drop_table
Post.create_table

last_user = User.last
p last_user.name

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

p post

user = post.user

user.create_post(title: "advance association", content: "checking advance assoiation create method")

p Post.find_by_title("advance association")
