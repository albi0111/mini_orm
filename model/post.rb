class Post < MiniRecord
  column :title, 'TEXT'
  column :content, 'TEXT'
  column :user_id, 'INTEGER'
  belongs_to :user
end
