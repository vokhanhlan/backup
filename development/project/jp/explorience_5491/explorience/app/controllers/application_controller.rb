class ApplicationController < ActionController::Base
  include Localizable
  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  http_basic_authenticate_with name: ENV['BASIC_AUTH_USERNAME'], password: ENV['BASIC_AUTH_PASSWORD'] if Rails.env == "staging" || Rails.env == "beta"

  def authenticate_admin_user!
    redirect_to new_admin_user_session_path unless admin_user_signed_in?
  end
end
