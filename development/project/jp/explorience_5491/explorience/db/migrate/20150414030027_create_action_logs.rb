class CreateActionLogs < ActiveRecord::Migration
  def change
    create_table :action_logs do |t|
      t.references :user, index: true
      t.integer :refered_experience_detail,    default: 0
      t.integer :refered_score_logs,           default: 0
      t.integer :refered_upload_photos,        default: 0
      t.integer :refered_menu_guide,           default: 0
      t.integer :refered_menu_privacy_policy,  default: 0
      t.integer :refered_user_page,            default: 0
      t.integer :refered_other_users_sns,      default: 0
      t.integer :refered_other_site,           default: 0
      t.integer :used_display_recommended,     default: 0
      t.integer :used_display_timeline,        default: 0
      t.integer :used_display_weekly_ranking,  default: 0
      t.integer :used_display_monthly_ranking, default: 0
      t.integer :used_display_map,             default: 0
      t.integer :used_filter_by_tag,           default: 0
      t.integer :used_change_settings,         default: 0
      t.integer :used_share_for_sns,           default: 0
      t.string  :visitor_ids

      t.timestamps
    end
  end
end
