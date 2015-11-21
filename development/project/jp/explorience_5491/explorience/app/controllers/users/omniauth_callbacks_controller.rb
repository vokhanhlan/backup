class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # TODO: HACK: 共通化
  def twitter
    # TODO: エラー処理フロー検討
    begin
      auth = request.env["omniauth.auth"]
      session[:oauth_token] = auth.credentials.token
      session[:oauth_token_secret] = auth.credentials.secret
      @user = User.find_for_twitter_oauth(auth, current_user)
      sign_in_and_redirect @user, event: :authentication
    rescue
      redirect_to root_path unauthenticated: auth.provider
    end
  end

  def facebook
    # TODO: エラー処理フロー検討
    begin
      @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
      sign_in_and_redirect @user, event: :authentication
    rescue
      redirect_to root_path unauthenticated: request.env["omniauth.auth"].provider
    end
  end

  def google
    begin
      @user = User.find_for_google_oauth(request.env["omniauth.auth"], current_user)
      sign_in_and_redirect @user, event: :authentication
    rescue
      redirect_to root_path unauthenticated: request.env["omniauth.auth"].provider
    end
  end

  protected
  def after_omniauth_failure_path_for(scope)
    # TODO: 適したパラメータ検討
    # request.path_info = /users/auth/PROVIDER/callback
    root_path unauthenticated: request.path_info.split("/")[3] || "sns"
  end
end
