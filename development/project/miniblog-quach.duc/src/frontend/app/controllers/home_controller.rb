class HomeController < ApplicationController
  def index
    # DESC===========================
    # Get all of Post to show in view
    # OUT: all record of Post
    # DESC===========================
    @posts = Post.where('status = 1').page(params[:page]).per(4).order('updated_at DESC')
  end
  def user_index
    # DESC===========================
    # Get all of User to show in view
    # OUT: all record of User
    # DESC===========================
     if params[:search_key]
      # Get list post with search key
      return @users = User.where('username LIKE :search_key OR first_name LIKE :search_key OR last_name LIKE :search_key',{ search_key: "%#{params[:search_key]}%" })
    end
    @users = User.all.page(params[:page]).per(8).order('updated_at DESC')
  end
end
