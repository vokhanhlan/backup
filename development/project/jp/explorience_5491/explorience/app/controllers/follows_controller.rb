class FollowsController < ApplicationController
  include Scorable

  after_action :update_read,  :only => [:follower_list]

  def follow
    user = current_user
    @following_id = params[:following_id]
    @following = user.follows.find_by(following_id: @following_id)
    following_user = User.find(@following_id)
    ActiveRecord::Base.transaction do
      if @following.present?
        @following.destroy
        subtract_bonus_for_followed_following(following_user, user)
      else
        user.follows.create!(following_id: @following_id)
        add_bonus_for_followed_following(following_user, user)
      end
    end
    @follower_count = Follow.where(following_id: @following_id).count
    respond_to do |format|
      format.js
    end
  end

  def following_list
    @unauthenticated = params[:unauthenticated]
    user_id = params[:user_id]
    following_ids = Follow.where(user_id: user_id).pluck(:following_id)
    @display_user = User.find(user_id)
    @followings = User.find(following_ids)
  end

  def follower_list
    @unauthenticated = params[:unauthenticated]
    user_id = params[:user_id]
    follower_ids = Follow.where(following_id: user_id).pluck(:user_id)
    @display_user = User.find(user_id)
    @followers = User.find(follower_ids)
  end

  def update_read
    if current_user.try(:id) == params[:user_id].to_i
      unread_followers = Follow.where(following_id: current_user.id, read: false)
      Follow.update_read(unread_followers) if unread_followers
    end
  end

end
