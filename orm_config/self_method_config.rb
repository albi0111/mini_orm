class MiniRecord
  def self.table_name
    name.downcase + 's'
  end

  def self.csv_file_path
    "db_data/#{table_name}.csv"
  end

  def self.column(name, type)
    @columns ||= {}
    @columns[name] = type

    attr_accessor name
  end

  def self.columns
    @columns
  end

  def self.create_table
    CSV.open(csv_file_path, "w") do |csv|
      csv << ["id", *columns.keys]
    end
  end

  def self.create(attributes)
    return if attributes.nil? || !attributes.is_a?(Hash)
    instance = new(attributes)
    instance.save
  end

  def self.drop_table
    File.delete(csv_file_path) if File.exist?(csv_file_path)
  end

  def self.all
    return [] unless File.exist?(csv_file_path)
    CSV.read(csv_file_path, headers: true).map do |row|
      instance = new
      row.each do |col, val|
        instance.send("#{col}=", val) if columns.keys.map(&:to_s).include?(col)
      end
      instance.instance_variable_set("@id", row["id"].to_i)
      instance
    end
  end

  def self.find(id)
    return nil unless File.exist?(csv_file_path)
    row = CSV.read(csv_file_path, headers: true).find { |row| row["id"].to_i == id }
    return nil unless row

    instance = new
    row.each do |col, val|
      instance.send("#{col}=", val) if columns.keys.map(&:to_s).include?(col)
    end
    instance.instance_variable_set("@id", row["id"].to_i)
    instance
  end

  def self.first
    return nil unless File.exist?(csv_file_path)
    row = CSV.read(csv_file_path, headers: true).min_by { |row| row[:id] }
    return nil unless row

    instance = new
    row.each do |col, val|
      instance.send("#{col}=", val) if columns.keys.map(&:to_s).include?(col)
    end
    instance.instance_variable_set("@id", row["id"].to_i)
    instance
  end

  def self.last
    return nil unless File.exist?(csv_file_path)
    row = CSV.read(csv_file_path, headers: true).max_by { |row| row[:id] }
    return nil unless row

    instance = new
    row.each do |col, val|
      instance.send("#{col}=", val) if columns.keys.map(&:to_s).include?(col)
    end
    instance.instance_variable_set("@id", row["id"].to_i)
    instance
  end
end
