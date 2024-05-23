class User < MiniRecord
  column :name, String.new
  column :email, String.new
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
