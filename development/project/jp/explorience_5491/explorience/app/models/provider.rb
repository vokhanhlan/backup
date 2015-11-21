# == Schema Information
#
# Table name: providers
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  sns_type   :integer          not null
#  sns_id     :string(255)      not null
#  nickname   :string(40)
#  photo_url  :string(255)
#  created_at :datetime
#  updated_at :datetime
#  language   :string(8)
#
# Indexes
#
#  index_providers_on_user_id  (user_id)
#

class Provider < ActiveRecord::Base
  belongs_to :user

  enum sns_type: {
    facebook: 0,
    twitter:  1,
    google:   2
  }

  # inclusionは定義しない（enumにより代入時例外発火するため）
  validates :sns_type, presence: true
  validates :sns_id,   presence: true
  validates :nickname, length: { maximum: 20 }
end
