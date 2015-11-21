# == Schema Information
#
# Table name: follows
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  following_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  read         :boolean          default(FALSE)
#
# Indexes
#
#  index_follows_on_user_id  (user_id)
#

class Follow < ActiveRecord::Base
  belongs_to :user
  
  # TODO: score_log.rbにも同様のメソッドがあるので共通化
  class << self
    def update_read(followers)
      unread_followers = []
      if followers
        followers.each do |follower|
          follower.read = true
          unread_followers << follower
        end
        import unread_followers.to_a, on_duplicate_key_update: [:read]
      end
    end
  end
  
end
