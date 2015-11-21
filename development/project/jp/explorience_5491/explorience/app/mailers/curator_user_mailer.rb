class CuratorUserMailer < ActionMailer::Base
  default from: 'support@explorience.jp'

  # TODO: UserMailer.sign_up_authentication(@user).deliver_later (call in controller need send mail)
  def sign_up_authentication(user_info)
    @user = user_info
    mail(to: @user.email, subject: '[explorience services] Authentication for sign up curator of explorience is succeed')
  end

  def complete_registration(user_info)
    @user = user_info
    mail(to: @user.email, subject: '[explorience services] Registration account  curator of explorience is completed')
  end

end