$ ->
  $(document).on 'click', '.follow-block__btn',  (event) ->
    ajax_post(event.currentTarget)

  ajax_post = (element)->
    $.ajax({
      type: "post"
      url: element.dataset['url']
      data: {following_id: element.dataset['user_id']}
      success: ()->
        console.log('Ajax POST was completed.')
        return false
      error: ()->
        console.log('Failed to Ajax POST.')
        return false
      })
