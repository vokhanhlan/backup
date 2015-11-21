module UsersHelper
  
  #掲載・非掲載のボタン文言切替
  def published_wording(photo_id)
    if Photo.find(photo_id).published == true
      I18n.t('helpers.users_helper.unpublished')
    else
      I18n.t('helpers.users_helper.published')
    end
  end
  
  #掲載・非掲載のclass切替
  def published_state(photo)
    (photo.published == false) ? 'unpublished' : ''
  end
  
  def unread_count(count)
    Constants::unread_counts > count ? count : "+"
  end
  
end