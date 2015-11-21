class PhotosController < ApplicationController
  include Scorable

  before_action :set_photo, except: [:create]
  before_action :set_user,    only: [:update_published, :destroy]

  def create
    ActiveRecord::Base.transaction do
      user = current_user
      photo = Photo.create!(photo_params) if params[:photo]
      photo.experience_photos.create(experience_id: params[:photo][:experience_id])
      photo.user_photos.create(user_id: user.id)
      experience_fixed_photo = FixedPhoto.find_by(user_id: user.id, experience_id: params[:photo][:experience_id])
      if experience_fixed_photo
        old_photo_id = experience_fixed_photo.photo_id
        experience_fixed_photo.update_attributes(photo_id: photo.id)
        add_and_subtract_bonus_for_pinned_photo(old_photo_id, photo.id)
      else
        FixedPhoto.create!(user_id: user.id,
                          experience_id: params[:photo][:experience_id],
                          photo_id: photo.id
                          )
        add_and_subtract_bonus_for_pinned_photo(nil, photo.id)
      end
      add_bonus_for_upload_photo
      flash[:upload_completed] = photo.id
      redirect_to experience_title_path(Experience.find(params[:photo][:experience_id]))
    end
  rescue
    flash[:errors] = t('controllers.photos_controller.upload_error')
    redirect_to :back
  end

  def update_published
    published = @photo.published
    @photo.update_attributes(published: !published)
    render
  rescue => e
    flash[:errors] = t('controllers.photos_controller.published_error')
    render
  end

  def destroy
    @deleted_photo_id = @photo.id
    ActiveRecord::Base.transaction do
      @photo.destroy
      subtract_bonus_for_upload_photo
    end
    @uploaded_photos_count = Photo.joins(:user_photos).where(user_photos: {user_id: current_user.id }).order(created_at: :desc).count
    render
  rescue => e
    flash[:errors] = t('controllers.photos_controller.photo_delete')
    render
  end

  def upload_photo_fixed
    user = current_user
    experience_id = params[:experience_id]
    photo_id = params[:photo_id]
    experience_fixed_photo = user.fixed_photos.find_by(experience_id: experience_id)
    ActiveRecord::Base.transaction do
      if experience_fixed_photo
        old_photo_id = experience_fixed_photo.photo_id
        experience_fixed_photo.update_attributes(photo_id: photo_id)
        add_and_subtract_bonus_for_pinned_photo(old_photo_id, photo_id)
      else
        FixedPhoto.create!(user_id: user.id,
                          experience_id: experience_id,
                          photo_id: photo_id
                          )
        add_and_subtract_bonus_for_pinned_photo(nil, photo_id)
      end
    end
    user_id = UserPhoto.find_by(photo_id: photo_id).try(:user_id)
    if user_id
      @upload_user_img = User.find(user_id).providers.first.photo_url
      @fixed_photo_count = FixedPhoto.where(photo_id: photo_id).count
    end
    respond_to do |format|
      format.js
    end
  end

  private

  def set_photo
    @photo = Photo.find(params[:photo_id])
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def photo_params
    params.require(:photo).permit(:img)
  end
end
