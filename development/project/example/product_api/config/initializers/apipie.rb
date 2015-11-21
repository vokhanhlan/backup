Apipie.configure do |config|
  config.app_name                = "ProductApi"
  #config.api_base_url            = "/api"
  config.api_base_url            = "/api/v1"
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  #config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/v1/*.rb"
  config.authenticate = Proc.new do
  authenticate_or_request_with_http_basic do |username, password|
       username == "test" && password == "123"
    end
  end
end
