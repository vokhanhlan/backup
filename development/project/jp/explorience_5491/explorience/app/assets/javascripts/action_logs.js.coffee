$ ->
  # ユーザーページのSNSリンクをクリック
  $('.user-name-sns-block__sns').find('a').on 'click', (event) ->
    ajax_post(event.currentTarget)

  # 体験詳細ページの外部URLリンクをクリック
  $('.detail-block__url a').on 'click', (event) ->
    ajax_post(event.currentTarget)

  # 設定画面のチェックボックスをクリック
  $('#settingCookieValue').on 'click', (event) ->
    ajax_post(event.currentTarget.parentElement.parentElement)

  ajax_post = (element)->
    $.ajax({
      type: "post"
      url: element.dataset['url']
      data: { column: element.dataset['column'] }
      success: ()->
        console.log('Ajax POST was completed.')
        return false
      error: ()->
        console.log('Failed to Ajax POST.')
        return false
      })
