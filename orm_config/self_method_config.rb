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

    define_singleton_method("find_by_#{name}") do |value|
      return unless value.is_a?(Integer) || value.is_a?(String) || name.blank?

      find(name.to_sym => value)
    end
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
    CSV.read(csv_file_path, headers: true).map { |row| new(row.to_h) }
  end


  def self.where(conditions)
    return [] unless File.exist?(csv_file_path)
    rows = CSV.read(csv_file_path, headers: true).select do |row|
      conditions.all? { |col, val| row[col.to_s] == val.to_s }
    end
    rows.map do |row|
      new(row.to_h)
    end
  end

  def self.find(conditions)
    return nil unless File.exist?(csv_file_path)
    conditions = {"id": conditions } if conditions.is_a?(Integer)
    where(conditions).first
  end

  def self.first
    return nil unless File.exist?(csv_file_path)
    row = CSV.read(csv_file_path, headers: true).min_by { |row| row[:id] }
    return nil unless row

    new(row.to_h)
  end

  def self.last
    return nil unless File.exist?(csv_file_path)
    row = CSV.read(csv_file_path, headers: true).max_by { |row| row[:id] }
    return nil unless row

    new(row.to_h)
  end
end
