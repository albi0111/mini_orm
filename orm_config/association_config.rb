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
    define_method(name) do
      Object.const_get(name.to_s.singularize.capitalize).where("#{self.class.name.downcase}_id" => id)
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
