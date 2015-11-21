# == Schema Information
#
# Table name: advertisers
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  ad_type    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class Advertiser < ActiveRecord::Base
  has_many :experiences

  enum ad_type: {
    pure_ad:     0,  # pure advertising
    affiliate_a: 1,  # affiliate type-A (High class)
    affiliate_b: 2,  # affiliate type-B (Normal)
    affiliate_c: 3,  # affiliate type-C (Low class)
    mail_ad:     4   # mail advertising
  }

  validates :name,    presence: true
  validates :ad_type, presence: true
end
