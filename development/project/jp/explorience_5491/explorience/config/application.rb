require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Explorience
  class Application < Rails::Application
    # NOTE: add smtp setting for project
    require File.expand_path('../smtp_setting', __FILE__)
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.time_zone = 'Tokyo'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    # TODO: 6/19リリースに向け、一時的に利用可能言語を:ja,:enに制限
    #config.i18n.fallbacks = [:en, :ja, :ko, :th]
    config.i18n.fallbacks = [:en, :ja]
    config.i18n.enforce_available_locales = true
    # Set supporting locales
    # TODO: 6/19リリースに向け、一時的に利用可能言語を:ja,:enに制限
    #config.i18n.available_locales = [:en, :ja, :ko, :th]
    config.i18n.available_locales = [:en, :ja]

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
