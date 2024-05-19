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

  # mini version of has_many
  # def self.has_many(name)
  #   define_method(name) do
  #     Object.const_get(name.to_s.singularize.capitalize).where("#{self.class.name.downcase}_id" => id)
  #   end
  # end

  # new version of has_may

  def self.has_many(name)
    singular_name = name.to_s.singularize

    define_method("#{name}_class") do
      Object.const_get(singular_name.capitalize)
    end

    define_method(name) do

      proxy_class = Class.new do
        define_method(:initialize) do |owner|
          @owner = owner
        end

        define_method(:where) do |conditions|
          owner_id_field = "#{@owner.class.name.downcase}_id"
          Object.const_get(singular_name.capitalize).where(conditions.merge(owner_id_field => @owner.id))
        end

        define_method(:create) do |attributes|
          clss = Object.const_get(singular_name.capitalize)
          attributes["#{@owner.class.name.downcase}_id".to_sym] = @owner.id
          clss.create(attributes)
        end

        define_method(:new) do |attributes=nil|
          attributes ||= {}
          clss = Object.const_get(singular_name.capitalize)
          attributes["#{@owner.class.name.downcase}_id".to_sym] = @owner.id
          clss.new(attributes)
        end

        define_method(:all) do
          Object.const_get(singular_name.capitalize).where("#{@owner.class.name.downcase}_id" => @owner.id)
        end
      end

      proxy_class.new(self)
    end
  end

  def self.has_one(name)
    define_method(name) do
      Object.const_get(name.to_s.singularize.capitalize).where("#{self.class.name.downcase}_id" => id).first
    end
  end

  def self.where(conditions)
    return [] unless File.exist?(csv_file_path)
    rows = CSV.read(csv_file_path, headers: true).select do |row|
      conditions.all? { |col, val| row[col.to_s] == val.to_s }
    end
    rows.map do |row|
      instance = new
      row.each do |col, val|
        instance.send("#{col}=", val) if columns.keys.map(&:to_s).include?(col)
      end
      instance.instance_variable_set("@id", row["id"].to_i)
      instance
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
