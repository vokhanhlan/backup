$ ->
  $('#uploadModalBlock').on 'click', ()->
    exp_id = $('.title-block').data('experience')
    $("#uploadModal_#{exp_id}").modal('show')

  $(document).on 'click', '.upload-modal-block', () ->
    exp_id = $(this).data('experience_id')
    $("#uploadModal_#{exp_id}").modal('show')

  if $('#mypageWrap').length > 0
    $(document).on 'click', '.uploaded-photo__img, .unpublished-block', ()->
      photo_id =
        if $(this).hasClass("unpublished-block")
          $(this).next().data('photo_id')
        else
          $(this).data('photo_id')
      $("#uploadedPhotoControlModal#{photo_id}").modal('show')

    $(document).on 'click', '.delete_confirm', ()->
      photo_id = $(this).data('photo_id')
      $("#uploadedPhotoControlModal#{photo_id}").modal('hide')
      $("#uploadedPhotoDeleteConfirmModal#{photo_id}").modal('show')

    $(document).on 'click', '#uploadedPhotoControlBtn, #uploadedPhotoDeleteBtn', (event) ->
      photo_id = $(this).data('photo_id')
      if ($(this).attr('id') == "uploadedPhotoControlBtn")
        target_modal = "#uploadedPhotoControlModal#{photo_id}"
      else
        target_modal = "#uploadedPhotoDeleteConfirmModal#{photo_id}"
      $(target_modal).modal().modal('hide')
      $('div.modal-backdrop.in').remove()
      ajax_post(event.currentTarget)

  ajax_post = (element) ->
    $.ajax({
      type: "POST"
      url: element.dataset['url']
      data: {
        photo_id: element.dataset['photo_id'],
        user_id: element.dataset['user_id']
       }
      success: ()->
        console.log('Ajax POST was completed.')
        return false
      error: ()->
        console.log('Failed to Ajax POST.')
        return false
    })