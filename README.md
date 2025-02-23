# Building a Mini ORM: Exploring Ruby Metaprogramming Magic

Object-Relational Mapping (ORM) frameworks like ActiveRecord are fundamental to modern web development, but have you ever wondered how they work under the hood? In this post, I'll walk you through building a minimal ORM using Ruby's powerful metaprogramming features. We'll create a system that handles basic database operations, associations, and even callbacks - all while storing data in CSV files for simplicity.

## The Core Foundation

At the heart of our Mini ORM is the `MiniRecord` class, which serves as the base class for our models. Let's look at how we define our models:

```ruby
class User < MiniRecord
  column :name, String.new
  column :email, String.new
  has_many :posts
  
  before_save :test_before_save
  after_save :test_after_save
  
  def test_before_save
    puts 'before save is working'
  end
  
  def test_after_save
    puts 'after save is working'
  end
end

class Post < MiniRecord
  column :title, String.new
  column :content, String.new
  column :user_id, 0
  belongs_to :user
end
```

This clean, declarative syntax hides a lot of metaprogramming magic happening behind the scenes. Let's dive into how it works.

## The Magic of Dynamic Method Creation

One of the most powerful features of our Mini ORM is the dynamic creation of methods for associations. Here's how we implement `belongs_to` and `has_many` relationships:

```ruby
def self.belongs_to(name)
  define_method(name) do
    foreign_key_value = send("#{name}_id")
    Object.const_get(name.to_s.capitalize).find(foreign_key_value)
  end
  
  define_method("#{name}=") do |obj|
    send("#{name}_id=", obj&.id)
  end
end

def self.has_many(name)
  singular_name = name.to_s.singularize
  define_method(name) do
    Object.const_get(singular_name.capitalize).where("#{self.class.name.downcase}_id" => id)
  end
end
```

This code uses `define_method` to dynamically create instance methods at runtime. When you declare `belongs_to :user` in the Post class, it automatically creates two methods:
- `user` - Returns the associated User object
- `user=` - Sets the relationship and updates the foreign key

## Callbacks System

Our ORM implements a simple but effective callback system:

```ruby
def self.before_save(method)
  @before_save_callbacks ||= []
  @before_save_callbacks << method
end

def self.after_save(method)
  @after_save_callbacks ||= []
  @after_save_callbacks << method
end

def self.run_callbacks(type, instance)
  callbacks = instance.class.instance_variable_get("@#{type}_callbacks")
  callbacks&.each { |callback| instance.send(callback) }
end
```

This system uses class instance variables to store callback methods and `send` to dynamically invoke them at the appropriate time.

## Dynamic Column Definition

The `column` method is another excellent example of metaprogramming:

```ruby
def self.column(name, type)
  @columns ||= {}
  @columns[name] = type
  attr_accessor name
  
  define_singleton_method("find_by_#{name}") do |value|
    return unless value.is_a?(Integer) || value.is_a?(String) || name.blank?
    find(name.to_sym => value)
  end
end
```

This method does three things:
1. Stores column information in a class variable
2. Creates getter and setter methods using `attr_accessor`
3. Dynamically defines finder methods like `find_by_email` or `find_by_title`

## Data Persistence

While not strictly metaprogramming, our persistence layer shows how we can use Ruby's reflection capabilities to save and retrieve data:

```ruby
def save
  self.class.run_callbacks(:before_save, self)
  self.class.create_table unless File.exist?(self.class.csv_file_path)
  data = CSV.table(self.class.csv_file_path)
  
  if @id
    data.each do |row|
      if row[:id] == @id
        self.class.columns.keys.each { |col| row[col] = send(col) }
        break
      end
    end
  else
    @id = data.any? ? data.max_by { |row| row[:id] }[:id] + 1 : 1
    data << [@id, *attribute_values]
  end
  
  File.open(self.class.csv_file_path, "w") { |f| f.write(data.to_csv) }
  self.class.run_callbacks(:after_save, self)
  self
end
```

## Using the Mini ORM

Using our ORM is straightforward and similar to ActiveRecord:

```ruby
# Create tables
Post.drop_table
Post.create_table

# Create and save records
last_user = User.last
post = Post.new
post.title = "Mini Orm"
post.content = "Orm With CSV"
post.user = last_user
post.save
```

## Conclusion

Building this Mini ORM demonstrates the power of Ruby's metaprogramming features. Through method_missing, define_method, and class instance variables, we've created a flexible system that provides much of the convenience of larger ORMs while remaining simple enough to understand.

The key metaprogramming concepts we've used include:
- Dynamic method definition with `define_method`
- Class instance variables for storing metadata
- Method delegation using `send`
- Constant lookup with `Object.const_get`
- Runtime class modification

While this implementation uses CSV files for storage, the same principles could be applied to build an ORM for any database system. The real power lies in Ruby's metaprogramming capabilities, which allow us to write clean, declarative code that gets transformed into powerful functionality at runtime.
