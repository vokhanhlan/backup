# == Schema Information
#
# Table name: action_logs
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  refered_experience_detail    :integer          default(0)
#  refered_score_logs           :integer          default(0)
#  refered_upload_photos        :integer          default(0)
#  refered_menu_guide           :integer          default(0)
#  refered_menu_privacy_policy  :integer          default(0)
#  refered_user_page            :integer          default(0)
#  refered_other_users_sns      :integer          default(0)
#  refered_other_site           :integer          default(0)
#  used_display_recommended     :integer          default(0)
#  used_display_timeline        :integer          default(0)
#  used_display_weekly_ranking  :integer          default(0)
#  used_display_monthly_ranking :integer          default(0)
#  used_display_map             :integer          default(0)
#  used_filter_by_tag           :integer          default(0)
#  used_change_settings         :integer          default(0)
#  used_share_for_sns           :integer          default(0)
#  visitor_ids                  :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#
# Indexes
#
#  index_action_logs_on_user_id  (user_id)
#

class ActionLog < ActiveRecord::Base
  belongs_to :user
end
