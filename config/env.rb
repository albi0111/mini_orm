# config/env.rb

# require_relative '../orm_config/mini_record'
# require_relative '../orm_config/association_config'
# require_relative '../orm_config/call_backs_config'

# require_relative '../model/user'
# require_relative '../model/post'

require_relative 'require_all'

# Require all files in the db_config directory
require_all('orm_config')
require_all('model')

# # # Manually require model files
# # require_relative '../model/user'
# # require_relative '../model/post'
