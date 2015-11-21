module CommentsHelper
  # Get user of post,comment,...
  def get_user_info(id)
    @user = User.find_by_id(id)
  end
end