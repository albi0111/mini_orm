class MiniRecord
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

    define_method(:where) do |conditions|
      owner_id_field = "#{self.class.name.downcase}_id"
      Object.const_get(singular_name.capitalize).where(conditions.merge(owner_id_field => id))
    end

    define_method("create_#{singular_name}") do |attributes|
      clss = Object.const_get(singular_name.capitalize)
      attributes["#{self.class.name.downcase}_id".to_sym] = id
      clss.create(attributes)
    end
  end


  def self.has_one(name)
    define_method(name) do
      Object.const_get(name.to_s.singularize.capitalize).find("#{self.class.name.downcase}_id" => id)
    end
  end
end

# just to singularize the words in simple structure if you want in large and accurate Use - Active Support gem
class String
  def singularize
    if end_with?('ies')
      self[0...-3] + 'y'
    elsif end_with?('s') && !end_with?('ss')
      self[0...-1]
    else
      self
    end
  end
end
