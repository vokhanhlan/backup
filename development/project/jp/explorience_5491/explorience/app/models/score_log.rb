# == Schema Information
#
# Table name: score_logs
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  other_user_id     :integer
#  scored_type       :integer          not null
#  placeholder_key   :string(255)
#  placeholder_value :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  read              :boolean          default(FALSE)
#
# Indexes
#
#  index_score_logs_on_user_id  (user_id)
#

class ScoreLog < ActiveRecord::Base
  belongs_to :user

  enum scored_type: {
    login:                      0,  # login
    click_wish_to_go:           1,  # check experience as wish to go
    click_been_there:           2,  # check experience as been there
    upload_photo:               3,  # upload photo
    pinned_photo:               4,  # pinned photo from someone
    followed:                   5,  # followed from someone
    following:                  6,  # following to someone
    activated_exp_by_click:     7,  # user checked experience has been activated by click
    activated_exp_by_modifying: 8   # user checked experience has been activated by modifying(or uploading photo)
  }

  validates :scored_type, presence: true

  # TODO: follow.rbにも同様のメソッドがあるので共通化
  class << self
    def update_read(score_logs)
      unread_logs = []
      if score_logs
        score_logs.each do |log|
          log.read = true
          unread_logs << log
        end
        import unread_logs.to_a, on_duplicate_key_update: [:read]
      end
    end
  end

  # instance methods

  # スコアタイプに従った履歴メッセージ出力
  def message
    placeholder = { placeholder_key.try(:to_sym) => placeholder_value }
    I18n.t "models.score_log.#{scored_type}", placeholder
  end
end
