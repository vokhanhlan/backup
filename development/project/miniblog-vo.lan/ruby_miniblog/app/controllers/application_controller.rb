class ApplicationController < ActionController::Base
  
  layout "application_v1"
  
  helper_method :current_user
  
  before_action :all_post

private
	def current_user
     @current_user ||= User.find(session[:user_id]) if session[:user_id]
      
	end

  def all_user
    @user = User.all

  end
  
  def all_post
    add_breadcrumb "Home", :homes_path
    @post_read_mores = Post.where("count_view > 0").order("count_view desc").limit(4)
    @posts = Post.all.paginate(:page => params[:page], :per_page => 4)

  end
end
