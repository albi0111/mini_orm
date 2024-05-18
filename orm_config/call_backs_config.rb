class MiniRecord
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
end
