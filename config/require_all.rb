# config/require_all.rb

def require_all(directory)
  Dir[File.join(directory, '*.rb')].each { |file| require_relative "../#{file}" }
end
