# == Schema Information
#
# Table name: clickings
#
#  id            :integer          not null, primary key
#  experience_id :integer
#  user_id       :integer
#  context       :integer          not null
#  deleted       :boolean          default(FALSE)
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_clickings_on_experience_id  (experience_id)
#  index_clickings_on_user_id        (user_id)
#

class Clicking < ActiveRecord::Base
  belongs_to :experience
  belongs_to :user

  enum context: {
    go:      0,  # Want to go there.
    went:    1   # Went to there.
  }

  scope :not_deleted, -> { where(deleted: false) }
  # inclusionは定義しない（enumにより代入時例外発火するため
  validates :context, presence: true

  class << self
    def calculate_score(experience)
      return 0 unless experience
      # 3種類のデータを少ないqueryで取得したいため、まずclickingsを取得
      # FIXME: 1queryで3種類のデータを取得することができるか？
      #   行く、行きたいではclickingsを利用したいが、また行きたいはclickingsでは不十分
      #   そのため、現状は、clickingsを取得し、click_count_of_usersを中間生成している
      clickings = experience.clickings.not_deleted.to_a

      click_count_of_users = clickings.inject(Hash.new(0)) do |hash, obj|
        hash[obj.user_id] += 1
        hash
      end
      count_of_going_again = click_count_of_users.values.count { |v| v == 2 }
      count_of_wish_to_go  = clickings.count { |cl| cl.context == "go" }
      count_of_been_there  = clickings.count { |cl| cl.context == "went" }

      (count_of_going_again * Constants.button_points.going_again) +
        (count_of_been_there * Constants.button_points.been_there) +
        (count_of_wish_to_go * Constants.button_points.wish_to_go)
    end
  end
end
