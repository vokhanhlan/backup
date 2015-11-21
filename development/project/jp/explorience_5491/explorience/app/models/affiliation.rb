# == Schema Information
#
# Table name: affiliations
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  action_type   :integer          not null
#  experience_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_affiliations_on_experience_id  (experience_id)
#

class Affiliation < ActiveRecord::Base
  belongs_to :experience

  enum action_type: {
    impression: 0,  # viewed contents detail
    click_link: 1   # clicked contents link
  }

  validates :action_type, presence: true
end
