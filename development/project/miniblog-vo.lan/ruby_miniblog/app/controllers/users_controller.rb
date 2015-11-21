class UsersController < ApplicationController

  before_action :set_user, only: [:edit,:update,:show]

  skip_before_action :verify_authenticity_token

  def index
    add_breadcrumb "All users", :users_path 
    @users = User.search_by_user(params[:search])

  end

  def new
    add_breadcrumb "Signup", :sign_up_path
    @user = User.new

  end

  def edit 
    add_breadcrumb "Edit profile", :edit_user_path

  end

  def show
    add_breadcrumb "Change password", :user_path

  end

  def create
#byebug
    @user = User.new(user_params)
    if @user.save
      redirect_to log_in_path, :notice => "Signed up!"
    else
      render "new"
    end
  end

  def update
    if params[:flag].present? 
      user = User.authenticate(current_user.username, params[:user][:password])
      if user
        @user.update(user_edit_params)
        redirect_to homes_path, user_update: 'User was successfully updated.'
      else
        flash[:user_update_f] = "Password current not validate, please entry password"
        render "edit"
      end
    else
      user = User.authenticate(current_user.username, params[:user][:password_old])
      if user 
        @user.update(user_change_password_params)
        flash[:change] = "Change password successfully"
        redirect_to user_path
      else
        flash[:change] = "Password current incorrect"
        redirect_to user_path
      end
    end
  end

  #get strong params 
  private

  def set_user
    @user = User.find(params[:id])

  end

  def user_params
    params.require(:user).permit(:email, :username, :first_name, :last_name, :display_name, :birthday, :avatar,:gender, :status, :password, :password_salt)

  end

  def user_edit_params
    params.require(:user).permit(:email, :username, :first_name, :last_name, :display_name, :birthday, :avatar,:gender,:address,:password, :password_salt)

  end

  def user_change_password_params
    params.require(:user).permit(:password, :password_salt)
    
  end

end