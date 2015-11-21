class ExperiencesController < ApplicationController
  before_action :signout_if_curator, only: :show
  include SnsPost
  def show
    @unauthenticated = params[:unauthenticated]
    @experience = Experience.find(params[:id])
    @default_photo_id = @experience.photos.first.id
    @click_users = @experience.clicking_users.clicked.without(current_user.try(:id)).with_providers
    @relation_tag_experiences = Experience.relation_tag_experiences(@experience)
    @experience_title = @experience.title
    @uploaded_experience_photos = @experience.photos.where(published: true).order(created_at: :desc)
    fixed_photo = FixedPhoto.find_by(user_id: current_user.try(:id), experience_id: @experience.id)
    user_photo = UserPhoto.find_by(photo_id: fixed_photo.try(:photo_id))
    if user_photo
      @upload_user_img = User.find(user_photo.user_id).providers.first.photo_url
      @fixed_photo_count = FixedPhoto.where(photo_id: fixed_photo.id).count
    end
    # Affiliate情報取得
    if @experience.advertiser.try(:affiliate_b?)
      Affiliation.create(
        experience_id: params[:id],
        user_id:       current_user.try(:id),
        action_type:   :impression
        )
    end
    current_user.count_action(:refered_experience_detail) if current_user
  end

  def twitter_post
    experience = Experience.find(params[:id])
    photo_img = Photo.find(params[:photo_id])
    # TODO:暫定対応
    photo_path = Rails.env.development? ? photo_img.img.path(:normal) : photo_img.img.url(:normal)
    twitter_photo_post(tweet_content(experience), photo_path)
    current_user.count_action(:used_share_for_sns)
    redirect_to :back
  end

  def dashboard
    @experience = Experience.last
  end

  private

  def tweet_content(experience)
    current_url = request.url
    current_url.slice!("/twitter")
    # NOTE: localhostだとtwitter上でURLと認識されないため、developmentでは本番サイトのurl入れておく
    http_domain = Rails.env.development? ? 'https://explorience.jp' : current_url
    content_without_url = "#{experience.title}\n#{experience.description}"
    "#{content_without_url.truncate(Constants.twitter.max_text_length)}#{http_domain + experience_path(experience.id)}"
  end

  def signout_if_curator
    if current_user.try(:user_type)
      sign_out
      redirect_to root_path
    end
  end
end
