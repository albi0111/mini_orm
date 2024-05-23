class Post < MiniRecord
  column :title, String.new
  column :content, String.new
  column :user_id, 0
  belongs_to :user
end
