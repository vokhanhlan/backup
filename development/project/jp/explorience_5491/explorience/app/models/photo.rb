# == Schema Information
#
# Table name: photos
#
#  id               :integer          not null, primary key
#  created_at       :datetime
#  updated_at       :datetime
#  img_file_name    :string(255)
#  img_content_type :string(255)
#  img_file_size    :integer
#  img_updated_at   :datetime
#  published        :boolean          default(TRUE)
#

class Photo < ActiveRecord::Base
  has_many :experience_photos, dependent: :destroy
  has_many :experiences, through: :experience_photos
  has_many :user_photos, dependent: :destroy
  has_many :users, through: :user_photos
  has_many :fixed_photos, dependent: :destroy
  has_attached_file :img,
    # NOTE: 現状はスマホ表示サイズに画像加工している
    #styles: { normal: '568x379>', :'normal@2x' => '1136x758>' },
    styles: { normal: '312x208#', :'normal@2x' => '624x416#' },
    default_url: "/missing.jpg"
  validates_attachment :img, content_type: { content_type: /\Aimage\/.*\Z/ }, presence: true
end
