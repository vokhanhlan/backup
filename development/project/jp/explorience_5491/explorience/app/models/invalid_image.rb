# == Schema Information
#
# Table name: invalid_images
#
#  id          :integer          not null, primary key
#  photo_id    :integer
#  uploader_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_invalid_images_on_photo_id     (photo_id)
#  index_invalid_images_on_uploader_id  (uploader_id)
#

class InvalidImage < ActiveRecord::Base
  has_many :reporters, dependent: :destroy
end
