class RankingsController < ApplicationController
  before_action :authenticate_user!

  def replace_rank
    unless current_user.rankings.find_by(rank: params[:dest_rank]).try(:locked)
      ranking = current_user.rankings.find_by(rank: params[:src_rank])
      unless ranking.locked
        update_rank = params[:lowest] ? current_user.rankings.maximum(:rank) + 1 : params[:dest_rank]
        ActiveRecord::Base.transaction do
          ranking.update_attributes(rank: update_rank)
          Ranking.reorder_rank(current_user)
        end
      end
    end

    # ranked experiences
    ranked_experiences = Experience.ranked_by(current_user).with_photos
    # TODO: 以下の記述動作できていれば、scope化
    unranked_experiences = Experience.filter_by_click_context('go', current_user).where.not(id: ranked_experiences.pluck(:id)).posted_order.with_photos
    @experience_ranking = Kaminari.paginate_array(ranked_experiences + unranked_experiences).limit(params[:exp_count])

    respond_to do |format|
      format.js
    end
  end

  def toggle_lock
    @ranking = Ranking.find_by(user_id: current_user.id, rank: params[:rank])
    @ranking.toggle_lock if @ranking
    respond_to do |format|
      format.js
    end
  end
end
