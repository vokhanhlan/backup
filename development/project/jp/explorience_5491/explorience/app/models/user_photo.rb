# == Schema Information
#
# Table name: user_photos
#
#  id         :integer          not null, primary key
#  photo_id   :integer
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_user_photos_on_photo_id  (photo_id)
#  index_user_photos_on_user_id   (user_id)
#

class UserPhoto < ActiveRecord::Base
  belongs_to :photo
  belongs_to :user
end
