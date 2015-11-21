Rails.application.configure do
  unless config.action_mailer.nil?
    # Read config info in smtp_config.yml
    options = YAML.load_file(Rails.root.join('config', 'smtp_config.yml'))[Rails.env]

    config.action_mailer.delivery_method = options["delivery_method"].to_sym
    config.action_mailer.default_url_options = { host: "#{options["host"]}" }


    config.action_mailer.smtp_settings = {
      address: options["address"],
      port: options["port"].to_i,
      domain: options["domain"],
      user_name: options["user_name"],
      password: options["password"],
      authentication: options["authentication"].to_sym,
      enable_starttls_auto: options["enable_starttls_auto"]
    }

  end
end
