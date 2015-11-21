# == Schema Information
#
# Table name: fixed_photos
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  experience_id :integer
#  photo_id      :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_fixed_photos_on_user_id  (user_id)
#

class FixedPhoto < ActiveRecord::Base
  belongs_to :user
  belongs_to :photo
end
