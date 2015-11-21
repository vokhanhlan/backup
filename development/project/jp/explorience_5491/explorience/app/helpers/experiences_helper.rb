module ExperiencesHelper
  def internationalized_phone(number)
    return number if I18n.locale == :ja
    return "#{number} (Toll Free)" if number =~ /\A0120/
    number.slice!(0)
    return "+81-#{number}"
  end

  #体験の画像をユーザー毎に変更
  def main_photo(experience, user=current_user)
    return Photo.new unless experience
    fixed_photo = FixedPhoto.find_by(user_id: user.id, experience_id: experience.id) if user
    if fixed_photo
      photo = Photo.find(fixed_photo.photo_id)
      photo.published ? photo : experience.photos.first
    else
      experience.photos.first
    end
  end

  def select_workday(exp)
    return "" unless exp
    if exp.start_date && exp.end_date
      t 'helpers.experiences_helper.fixed_period', start: exp.start_date.to_date, end: exp.end_date.to_date
    else
      exp.workday
    end
  end

  # current_userの再訪判定
  # TODO: userモデルに実装した方がよい。後でリファクタ
  def current_user_wish_going_again?(exp_id)
    return false unless current_user
    current_user.clickings.where(experience_id: exp_id, deleted: false).count >= 2
  end
end
