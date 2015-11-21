class ClickingsController < ApplicationController
  include Scorable

  before_action :authenticate_user!
  before_action :validate_params

  def clicking
    exp_id   = params[:experience_id]
    @context = params[:context]
    # TODO HACK: modelにメソッド定義して分かりやすくする
    past_clicking = Clicking.__send__(@context.to_s).find_by(experience_id: exp_id, user_id: current_user.id)

    if past_clicking.nil?
      # 1st clicking
      if current_user.clickable?(exp_id)
        # create new record
        new_clicking = Clicking.new(clicking_params)
        new_clicking.user_id = current_user.id
        ActiveRecord::Base.transaction do
          if new_clicking.save && create_ranking(@context, exp_id)
            add_bonus_for_click(@context)
            add_bonus_for_activated_exp_by_click(exp_id, @context)
            @experience_clicking = Experience.find(new_clicking.experience_id)
          else
            flash[:errors] = []
            render js: "window.location = '#{request.env["HTTP_REFERER"]}'"
          end
        end
      else
        over_clicking_times_error
      end
    else
      # 2nd or more clicking (toggle deleted flag)
      if !past_clicking.deleted || current_user.clickable?(exp_id)
        deleted = past_clicking.deleted
        ActiveRecord::Base.transaction do
          if past_clicking.update_attributes(deleted: !deleted) &&
             create_or_delete_ranking(@context, exp_id, deleted)
            add_bonus_for_click(@context)
            add_bonus_for_activated_exp_by_click(exp_id, @context)
            @experience_clicking = Experience.find(past_clicking.experience_id)
          else
            flash[:errors] = []
            render js: "window.location = '#{request.env["HTTP_REFERER"]}'"
          end
        end
      else
        over_clicking_times_error
      end
    end
    update_score_of_experience(exp_id)
  end

  def click_cancel
    exp_id   = params[:experience_id]
    @context = params[:context]
    # TODO HACK: modelにメソッド定義して分かりやすくする
    past_clicking = Clicking.__send__(@context.to_s).find_by(experience_id: exp_id, user_id: current_user.id)
    deleted = past_clicking.deleted
    if past_clicking.update_attributes(deleted: !deleted) &&
       create_or_delete_ranking(@context, exp_id, deleted)
      subtract_bonus_for_click(@context)
      subtract_bonus_for_activated_exp_by_click(exp_id, @context)
      @experience_clicking = Experience.find(exp_id)
    else
      flash[:errors] = []
      render js: "window.location = '#{request.env["HTTP_REFERER"]}'"
    end
    update_score_of_experience(exp_id)
  end

  private

  # TODO HACK: 緊急対処のため、要リファクタ(raiseさせてaction側でrescue後にrenderした方がよいかも)
  # パラメータ検証（主にcontext）
  def validate_params
    context = params[:context]
    if context.nil? || (context != 'go' && context != 'went')
      flash[:errors] = []
      render js: "window.location = '#{request.env["HTTP_REFERER"]}'"
    end
  end

  def over_clicking_times_error
    errors = []
    errors << t('controllers.clickings_controller.over_clicking_times_error.notice')
    errors << t('controllers.clickings_controller.over_clicking_times_error.guidance')
    flash[:errors] = errors
    render js: "window.location = '#{request.env["HTTP_REFERER"]}'"
  end

  def update_score_of_experience(exp_id)
    return unless exp_id
    exp = Experience.find(exp_id)
    exp.update_attributes(score: Clicking.calculate_score(exp))
  end

  # ユーザーの行きたいランキングレコード生成
  #   ユーザーのランキングが100位まで決定している場合には、ランキング再整列する
  #   戻り値は true(or Ranking object) or false
  def create_ranking(context, experience_id)
    return true unless context == 'go'
    new_rank = current_user.rankings.new_rank
    current_user.rankings.create(experience_id: experience_id, rank: new_rank)
    current_user.rankings.count > 1 ? Ranking.reorder_rank(current_user) : true
  rescue
    false
  end

  # ユーザーの行きたいランキングレコード生成/削除
  #   変更前のclickingが削除状態の場合はrankingレコード生成
  #   非削除状態の場合にはrankingレコードを削除し、ランキング再整列する
  #   戻り値はtrue or false
  def create_or_delete_ranking(context, experience_id, clicking_deleted)
    return true unless context == 'go'
    if clicking_deleted
      create_ranking(context, experience_id)
    else
      ranking = current_user.rankings.find_by(experience_id: experience_id)
      if ranking
        ranking.destroy
        Ranking.reorder_rank(current_user)
        ranked_experiences = Experience.ranked_by(current_user)
        unranked_clickings = current_user.clickings.where(context: "go").not_deleted.where.not(experience_id: ranked_experiences.pluck(:id)).order(updated_at: :desc)
        if current_user.rankings.count < Constants.max_rank && unranked_clickings.present?
          current_user.rankings.create!(experience_id: unranked_clickings.first.experience_id, rank: Constants.max_rank)
        end
      end
      true
    end
  rescue
    false
  end

  def clicking_params
    params.permit(
      :experience_id,
      :context
    )
  end
end
