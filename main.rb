require_relative 'config/env'


last_user = User.last

post = Post.new
post.title = "Mini Orm"
post.content = "Orm With CSV"
post.user = last_user
post.save

user = post.user
# print user.inspect
print user.posts
