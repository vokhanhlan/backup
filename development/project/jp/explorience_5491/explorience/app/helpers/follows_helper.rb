module FollowsHelper
  def follow_btn_class(user)
    following = current_user.follows.where(following_id: user.id) if user_signed_in?
    if following.blank?
      ""
    else
      "followed"
    end
  end
end
