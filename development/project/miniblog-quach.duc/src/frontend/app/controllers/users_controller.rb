class UsersController < ApplicationController
  include ImagesUpload
  before_action :set_post, only: [:show, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    # Funtion upload image and validate
    # TODO: short code
    if avatar_params[:avatar]
      if ["image/svg","image/gif"].include?(avatar_params[:avatar].content_type.to_s)
         flash[:alert] = "File extention fail (svg,gif)"
         render :new and return
      elsif avatar_params[:avatar].size > 1000000
         flash[:alert] = "File size much be < 1MB"
         render :new and return
      else
        ImagesUpload.upload(@user, avatar_params, "avatar")
      end
    end
    if @user.save
      redirect_to log_in_path,:flash => { :notice => "Signed up success, can login to system !", :user_name => @user[:username] }
    else
      render :new
    end
  end

  def edit
  end

  def show
  end

  def update
    if @user.update(user_params)
      if avatar_params[:avatar]
        if ["image/svg","image/gif"].include?(avatar_params[:avatar].content_type.to_s)
          flash[:alert] = "File extention fail (svg,gif)"
          render :new and return
        elsif avatar_params[:avatar].size > 1000000
          flash[:alert] = "File size much be < 1MB"
          render :new and return
        else
          ImagesUpload.upload(@user, avatar_params, "avatar")
        end
    end
      redirect_to '/users/'+@user[:id].to_s, :flash => { :notice => "Update profile successfully"}
    else
      render :edit and return
    end
  end


  def index
    redirect_to sign_up_path
  end



private
def set_post
  @user = User.find(params[:id])
end

def avatar_params
  params.require(:user).permit(:avatar,:username)
end

def user_params
  params.require(:user).permit(:email,:username,:first_name,:last_name,:address,:gender,:birthday,:avatar, :password, :password_confirmation)
end
end

