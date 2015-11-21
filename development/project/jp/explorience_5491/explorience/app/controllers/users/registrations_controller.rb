class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters

  def create
    @user = User.find_or_initialize_by(email: sign_up_params[:email]) do |u|
      u.attributes = sign_up_params
    end
    if @user.persisted?
      flash[:error] = ["Email already exists"]
      redirect_to new_user_registration_path
    elsif @user.save
      redirect_to new_user_session_path, :flash => { :error => "Check email and confirm info" }
    else
      flash[:error] = @user.errors.full_messages
      redirect_to new_user_registration_path
    end
  end

  private
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :name, :password, :password_confirmation).tap do |attrs|
        attrs[:user_type] = "curator"
      end
    end
  end

end
