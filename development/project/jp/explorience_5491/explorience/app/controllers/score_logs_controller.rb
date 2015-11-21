class ScoreLogsController < ApplicationController
  before_action :authenticate_user!
  after_action  :update_read

  def index
    @score_logs = current_user.score_logs.order(created_at: :desc).limit(20)
    current_user.count_action(:refered_score_logs) if current_user
  end

  def update_read
    unread_score_logs = current_user.score_logs.where(read: false)
    ScoreLog.update_read(unread_score_logs) if unread_score_logs
  end

end
