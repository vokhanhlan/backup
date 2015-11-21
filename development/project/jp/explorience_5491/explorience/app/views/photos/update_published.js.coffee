photo_id = "<%= @photo.id %>"
$("#uploadedPhotoControl#{photo_id}").html("<%= j(render partial: 'shared/uploaded_photo_control_modal', locals: {photo_id: @photo.id}) %>")
$("#uploadedPhotoDeleteConfirm#{photo_id}").html("<%= j(render partial: 'shared/uploaded_photo_delete_confirm',  locals: {photo_id: @photo.id}) %>")
$("#unPublished#{photo_id}").html("<%= j(render partial: "users/unpublish", locals: {uploaded_photo: @photo}) %>")

if "<%= @photo.published %>" == "true"
  $(".uploaded-photo__img[data-photo_id=#{photo_id}]").removeClass("unpublished")
else
  $(".uploaded-photo__img[data-photo_id=#{photo_id}]").addClass("unpublished")


