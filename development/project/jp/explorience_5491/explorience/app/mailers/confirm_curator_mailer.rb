class ConfirmCuratorMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'

  def confirmation_instructions(record, token, opts={})
    opts[:from] = 'support@explorience.jp'
    opts[:reply_to] = 'support@explorience.jp'
    opts[:subject] = '[explorience services] Confirm email for account'
    super
  end
end