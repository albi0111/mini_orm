class User < MiniRecord
  column :name, 'TEXT'
  column :email, 'TEXT'
  has_many :posts

  attr_reader :id

  before_save :test_before_save
  after_save :test_after_save

  def test_before_save
    puts 'before save is working'
  end

  def test_after_save
    puts 'after save is working'
  end
end
