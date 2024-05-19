class MiniRecord
  def self.belongs_to(name)
    define_method(name) do
      foreign_key = send("#{name}_id")
      Object.const_get(name.to_s.capitalize).find(foreign_key)
    end

    define_method("#{name}=") do |obj|
      send("#{name}_id=", obj.id)
    end
  end

  def self.has_many(name)
    define_method(name) do
      Object.const_get(name.to_s.singularize.capitalize).where("#{self.class.name.downcase}_id" => id)
    end
  end

  def self.has_one(name)

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
