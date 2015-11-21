# == Schema Information
#
# Table name: reporters
#
#  id               :integer          not null, primary key
#  invalid_image_id :integer
#  user_id          :integer
#  email            :string(255)      default(""), not null
#  invalid_type     :integer          not null
#  reason           :text(65535)
#  created_at       :datetime
#  updated_at       :datetime
#
# Indexes
#
#  index_reporters_on_invalid_image_id  (invalid_image_id)
#  index_reporters_on_user_id           (user_id)
#

class Reporter < ActiveRecord::Base
  belongs_to :invalid_image

  enum invalid_type: {
    copylight:     0,  # 著作権違反
    social_ethics: 1,  # 公序良俗違反
    others:        2   # その他
  }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # NOTE: inclusionは定義しない（enumにより代入時例外発火するため）
  validates :invalid_type, presence: true
  validates :email,        presence: true, format: { with: VALID_EMAIL_REGEX }
end
