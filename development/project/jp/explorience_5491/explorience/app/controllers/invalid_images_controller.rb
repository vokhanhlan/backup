class InvalidImagesController < ApplicationController
  def create
    photo_id     = params[:invalid_image][:photo_id]
    reporter_id  = params[:invalid_image][:reporter_id]
    email        = params[:email]
    invalid_type = params[:invalid_type]
    reason       = params[:reason]

    ActiveRecord::Base.transaction do
      invalid_image = InvalidImage.find_by(photo_id: photo_id)
      unless invalid_image
        invalid_image = InvalidImage.create!(
          photo_id:    photo_id,
          uploader_id: Photo.find(photo_id).users.first.id
        )
      end
      invalid_image.reporters.create!(
        user_id:      reporter_id,
        email:        email,
        invalid_type: invalid_type.to_i,
        reason:       reason
      )
    end
    # TODO HACK: 完了モーダル制御をajax化したいが理解・実装時間考慮し、flashで実装
    flash[:report_completed] = true
    redirect_to :back
  rescue => ex
    flash[:errors] = []
    flash[:errors] << t('controllers.invalid_images_controller.report.failed_to_create')
    flash[:errors] << ex.message
    redirect_to :back
  end
end
