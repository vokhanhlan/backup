class Clicking
  @init: () ->
    this.bindingAjaxHandler()
    hide_cancel_modal()
    show_revisit_modal()

  @bindingAjaxHandler: () ->
    $(document).on 'click', '[data-context]', (event) ->
      if $('#login').length == 0
        if $(event.currentTarget).hasClass('btn-block__btn-go--checked') || $(event.currentTarget).hasClass('btn-block__btn-went--checked')
          show_cancel_modal(event.currentTarget)
        else
          ajax_post(event.currentTarget)
      return false

  ajax_post = (element) ->
    $.ajax({
      type: "POST"
      url: element.dataset['url']
      data: {
        experience_id: element.dataset['experience_id']
        context:       element.dataset['context']
      }
      success: ()->
        console.log('Ajax POST was completed.')
        return false
      error: ()->
        console.log('Failed to Ajax POST.')
        return false
    })

  show_cancel_modal = (element) ->
    unless $("html.mm-opened").length > 0
      target_id = $(element).find('[data-target]').data('target')
      $(target_id).modal()
    return false

  hide_cancel_modal = () ->
    # キャンセルモーダルを消す
    $(document).on 'click', '.btn--cancel', () ->
      $(this).parents('.modal.fade').modal('hide')

  show_revisit_modal = () ->
    $(document).on 'click', '.icon-revisit', () ->
      # ボタンをクリックしたときID名を変えているので、変わっていたら戻す処理
      if $('#clickRevisitModal').length > 0
        $('#clickRevisitModal').attr('id','revisitModal')
      $("#revisitModal").modal('show')
      return false

Clicking.init()
$ ->
  # show error modal
  if $('#errorModal').length > 0
    $('#errorModal').modal('show')
