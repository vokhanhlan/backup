# == Schema Information
#
# Table name: experience_photos
#
#  id            :integer          not null, primary key
#  photo_id      :integer
#  experience_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_experience_photos_on_experience_id  (experience_id)
#  index_experience_photos_on_photo_id       (photo_id)
#

class ExperiencePhoto < ActiveRecord::Base
  belongs_to :photo
  belongs_to :experience
end
