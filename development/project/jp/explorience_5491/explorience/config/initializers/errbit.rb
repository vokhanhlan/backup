# Load setting for each envrironment from ENV through yml file.
Airbrake.configure do |config|
  yml = Rails.application.config_for(:errbit)
  config.api_key = yml["api_key"]
  config.host    = yml["host"]
  config.port    = yml["port"]
  config.secure  = yml["secure"]
end
