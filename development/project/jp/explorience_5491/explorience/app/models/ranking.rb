# == Schema Information
#
# Table name: rankings
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  experience_id :integer
#  rank          :integer
#  locked        :boolean          default(FALSE)
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_rankings_on_experience_id  (experience_id)
#  index_rankings_on_user_id        (user_id)
#

class Ranking < ActiveRecord::Base
  belongs_to :experience
  belongs_to :user

  # Scopes
  scope :locked,        -> { where(locked: true)      }
  scope :unlocked,      -> { where(locked: false)     }
  scope :rank_order,    -> { order(rank: :asc)        }
  scope :updated_order, -> { order(updated_at: :desc) }

  # Class methods
  class << self
    def reorder_rank(user)
      return false unless user.is_a?(User)
      return true  if user.rankings.empty?

      locked_ranks = user.rankings.locked.pluck(:rank)
      expected_rank = 1
      while locked_ranks.include?(expected_rank)
        expected_rank += 1
      end

      update_rankings = []
      user.rankings.rank_order.updated_order.each do |ranking|
        unless ranking.locked
          unless ranking.rank == expected_rank
            if expected_rank > Constants.max_rank
              ranking.destroy
            else
              ranking.rank = expected_rank
              update_rankings << ranking
            end
          end
          # Skip next expected rank if next rank had locked.
          begin
            expected_rank += 1
          end while locked_ranks.include?(expected_rank)
        end
      end
      import update_rankings.to_a, on_duplicate_key_update: [:rank] if update_rankings.present?
      true
    rescue
      false
    end

    # lockされていない最上位のランクを取得
    def new_rank
      return 1 if count == 0
      set_rank = 0
      order(:rank).each do |ranking|
        next if ranking.locked
        set_rank = ranking.rank
        break
      end
      set_rank = Constants.max_rank + 1 if set_rank == 0
      set_rank
    end
  end

  # Instance methods
  def toggle_lock
    self.locked = !self.locked
    save!
  end
end
