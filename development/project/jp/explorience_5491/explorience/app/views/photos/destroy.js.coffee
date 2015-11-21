$(".uploaded-photo__img[data-photo_id='<%= @deleted_photo_id %>']").parent().remove()
$("#uploadedPhotoControl<%= @deleted_photo_id %>, #uploadedPhotoDeleteConfirm<%= @deleted_photo_id %>").remove()

$("a[href='#tabPanelPhotos']").text("<%= t 'views.users._user_layout.tabs.photos', count: @uploaded_photos_count %>")