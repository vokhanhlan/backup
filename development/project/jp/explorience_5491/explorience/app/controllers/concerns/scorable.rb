module Scorable
  extend ActiveSupport::Concern

  # ユーザースコア更新および履歴記録
  #   user    : Userオブジェクト
  #   context : ScoreLog.scored_typeに定義したstringをsymbolで
  #   hash    : 以下のkeyと値を持つhash
  #     counts : prev,currentのkeyに変化前後のcount値をvalueに持つhash
  #     type   : 加減算タイプ(:incr or :decr)
  def update_score(user, context, hash={})
    bonus = bonus_score(context, hash[:counts])
    if bonus > 0
      if hash[:type] == :incr
        user.increment!(:score, bonus)
        user.score_logs.create(scored_type: context)
      else
        user.decrement!(:score, bonus)
      end
    end
  end

  # ボーナススコア加減算値の算出
  #   contextにはconstants.ymlに定義したkey名、
  #   countsには以下のkeyを持つhashを与えること
  #     prev:    変化前の行動回数
  #     current: 変化後の行動回数
  def bonus_score context, counts={}
    return 0 unless counts[:prev] && counts[:current]
    prev_stage    = 0
    current_stage = 0
    reference_values = Constants.user_score.reference_value.try(context)
    bonus_points     = Constants.user_score.bonus_points.try(context)
    return 0 unless reference_values && bonus_points
    reference_values.each_with_index do |ref, i|
      stage = i + 1
      prev_stage    = stage if counts[:prev]    >= ref
      current_stage = stage if counts[:current] >= ref
    end
    return 0 if prev_stage == current_stage
    prev_stage < current_stage ? bonus_points[current_stage-1] : bonus_points[prev_stage-1]
  end

  # カウント変化情報の生成
  #   type: カウント値の変化状態を指定（incr,decr）
  def count_transition(count, type=:incr)
    diff = type == :incr ? -1 : 1
    { prev: count + diff, current: count }
  end

  # 継続ログイン時のスコア加算

  # TODO HACK: Scorable::update_scoreを使用せず、直接更新しているため、要リファクタ
  def add_bonus_for_login
    return unless current_user
    last_checking_date = current_user.last_sign_in_checking_at
    if last_checking_date
      passed_day = (Time.zone.now.to_date - last_checking_date.to_date).to_i
      if passed_day > 0 && passed_day <= Constants.user_score.reference_value.login.term_of_bonus
        bonus = Constants.user_score.bonus_points.login
        current_user.increment!(:score, bonus)
        current_user.score_logs.create(scored_type: :login)
      end
    end
    current_user.update_attributes(last_sign_in_checking_at: Time.zone.now)
  end

  # 体験クリック時のスコア加減算

  def add_bonus_for_click(context)
    score_context = context.to_sym == :go ? :click_wish_to_go : :click_been_there
    counts = count_transition(current_user.clickings.__send__(context).not_deleted.count, :incr)
    update_score(current_user, score_context, { counts: counts, type: :incr })
  end

  def subtract_bonus_for_click(context)
    score_context = context.to_sym == :go ? :click_wish_to_go : :click_been_there
    counts = count_transition(current_user.clickings.__send__(context).not_deleted.count, :decr)
    update_score(current_user, score_context, { counts: counts, type: :decr })
  end

  # 体験クリック時、過去にクリックしたユーザーへのスコア加算

  # TODO HACK: Scorable::update_scoreを使用せず、直接更新しているため、要リファクタ
  def add_bonus_for_activated_exp_by_click(exp_id, context)
    clickings = Clicking.__send__(context).not_deleted.where(experience_id: exp_id).order(updated_at: :desc)
    references = Constants.user_score.reference_value.activated_exp_by_click
    references.each_with_index do |ref, i|
      break if clickings.size < (ref+1)
      user = User.find(clickings[ref].user_id)
      add_bonus = Constants.user_score.bonus_points.activated_exp_by_click[i]
      user.increment!(:score, add_bonus)
      user.score_logs.create(scored_type: :activated_exp_by_click)
    end
  end

  # TODO HACK: Scorable::update_scoreを使用せず、直接更新しているため、要リファクタ
  def subtract_bonus_for_activated_exp_by_click(exp_id, context)
    clickings = Clicking.__send__(context).not_deleted.where(experience_id: exp_id).order(updated_at: :desc)
    references = Constants.user_score.reference_value.activated_exp_by_click
    references.each_with_index do |ref, i|
      break if clickings.size < ref
      user = User.find(clickings[ref-1].user_id)
      sub_bonus = Constants.user_score.bonus_points.activated_exp_by_click[i]
      user.decrement!(:score, sub_bonus)
    end
  end

  # 画像アップロード時のスコア加減算

  def add_bonus_for_upload_photo
    counts = count_transition(current_user.photos.count, :incr)
    update_score(current_user, :upload_photo, { counts: counts, type: :incr })
  end

  def subtract_bonus_for_upload_photo
    counts = count_transition(current_user.photos.count, :decr)
    update_score(current_user, :upload_photo, { counts: counts, type: :decr })
  end

  # 画像ピン留め（固定設定）時のスコア加減算

  def pinned_user(photo_id)
    return nil unless photo_id
    photo = Photo.find(photo_id)
    photo.users.try(:first)
  end

  def add_and_subtract_bonus_for_pinned_photo(old_photo_id, new_photo_id)
    old_pinned_user = pinned_user(old_photo_id)
    new_pinned_user = pinned_user(new_photo_id)
    add_bonus_for_pinned_photo(new_pinned_user)
    subtract_bonus_for_pinned_photo(old_pinned_user)
  end

  def add_bonus_for_pinned_photo(user)
    return unless user
    photo_ids = user.user_photos.pluck(:photo_id)
    counts = count_transition(FixedPhoto.where(photo_id: photo_ids).where.not(user_id: user.id).count, :incr)
    update_score(user, :pinned_photo, { counts: counts, type: :incr })
  end

  def subtract_bonus_for_pinned_photo(user)
    return unless user
    photo_ids = user.user_photos.pluck(:photo_id)
    counts = count_transition(FixedPhoto.where(photo_id: photo_ids).where.not(user_id: user.id).count, :decr)
    update_score(user, :pinned_photo, { counts: counts, type: :decr })
  end

  # フォロー/フォロー解除時のスコア加減算

  def add_bonus_for_followed_following(target_user, follower)
    add_bonus_for_followed(target_user)
    add_bonus_for_following(follower)
  end

  def subtract_bonus_for_followed_following(target_user, follower)
    subtract_bonus_for_followed(target_user)
    subtract_bonus_for_following(follower)
  end

  def add_bonus_for_followed(user)
    return unless user
    counts = count_transition(Follow.where(following_id: user.id).count, :incr)
    update_score(user, :followed, { counts: counts, type: :incr })
  end

  def subtract_bonus_for_followed(user)
    return unless user
    counts = count_transition(Follow.where(following_id: user.id).count, :decr)
    update_score(user, :followed, { counts: counts, type: :decr })
  end

  def add_bonus_for_following(user)
    return unless user
    counts = count_transition(user.follows.count, :incr)
    update_score(user, :following, { counts: counts, type: :incr })
  end

  def subtract_bonus_for_following(user)
    return unless user
    counts = count_transition(user.follows.count, :decr)
    update_score(user, :following, { counts: counts, type: :decr })
  end
end
