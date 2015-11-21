class Affiliation
  @init: () ->
    this.bindAffiliateButtonClickHandler()

  @bindAffiliateButtonClickHandler: () ->
    $(document).on 'click', '#affiliateButton', (event) ->
      ajaxPost(event.currentTarget, 'click_link')

  ajaxPost = (element, userAction) ->
    $.ajax({
      type: "POST"
      url: element.dataset['url']
      data: {
        experience_id: element.dataset['experienceId']
        user_id:       element.dataset['userId']
        action_type:   userAction
      }
      success: () ->
        console.log('Ajax POST was completed.')
        return false
      error: (xhr, textStatus, errorThrown) ->
        console.log('Failed to Ajax POST: ' + textStatus)
        return false
    })

Affiliation.init()
