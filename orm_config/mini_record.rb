require 'csv'

class MiniRecord
  def initialize(attr = nil)
    return if attr.nil? || !attr.is_a?(Hash)
    attr.each do |col, val|
      val = val.to_i if col.end_with?("id")
      send("#{col}=", val) if self.class.columns.keys.map(&:to_s).include?(col)
    end
    instance_variable_set("@id", attr["id"].to_i) if attr["id"]
    self
  end

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

  def update(attributes)
    return nil unless File.exist?(self.class.csv_file_path) && @id
    data = CSV.table(self.class.csv_file_path)
    record = data.find { |row| row[:id] == @id }
    attributes.each do |col, val|
      if self.class.columns.keys.include?(col)
        record[col] = val
      end
    end
    File.open(self.class.csv_file_path, "w") { |f| f.write(data.to_csv) }
    self.class.find(@id)
  end

  def delete
    return nil unless File.exist?(self.class.csv_file_path) && @id
    data = CSV.table(self.class.csv_file_path)
    data.delete_if { |row| row[:id] == @id }
    File.open(self.class.csv_file_path, "w") { |f| f.write(data.to_csv) }
  end

  def attribute_values
    self.class.columns.keys.map { |col| send(col) }
  end
end
