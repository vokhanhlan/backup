uploadImg = $('.experience-photo-block')
uploadImg.html("<%= j(render partial: 'experiences/main_photo',locals: {main_photo: @photo, upload_user_img: @upload_user_img, fixed_photo_count: @fixed_photo_count, default_photo_id: @default_photo_id}) %>")

$('.report-modal').html("<%= j(render partial: 'shared/report_modal', locals: { photo_id: @photo.id }) %>")