Rails.application.console do
  include FactoryBot::Syntax::Methods

  puts "Loaded custom initializer #{__FILE__}"

  Rails.logger.level = 0
  puts 'SQL logs enabled'

  ApplicationController.allow_forgery_protection = false
  puts "CSRF disabled to enable app.post calls"
end
