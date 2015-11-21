class ActionLogsController < ApplicationController
  def action_log_increase
    if current_user && params[:column]
      current_user.count_action(params[:column].to_sym)
    end
    render nothing: true
  end
end
