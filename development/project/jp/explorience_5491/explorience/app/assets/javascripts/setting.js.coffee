$ ->
  # cookieの有効期限を20年に設定
  expiration_days = 365 * 20
  # 再訪モーダルのチェックボタンのvalue切替
  $('#revisitCookieValue').on 'change', ->
    if $(this).is(':checked')
      $.cookie('setting_going_again_modal', 'hide', { expires: expiration_days })
    else
      $.cookie('setting_going_again_modal', 'show', { expires: expiration_days })
  # 設定画面のチェックボックスのvalue切替
  $('#settingCookieValue').on 'change', ->
    if $(this).is(':checked')
      $.cookie('setting_going_again_modal', 'show', { expires: expiration_days })
    else
      $.cookie('setting_going_again_modal', 'hide', { expires: expiration_days })
  # 再訪モーダル、設定画面の表示切替
  if $.cookie('setting_going_again_modal') == "hide"
    $("#revisitCookieValue").prop('checked',true)
    $("#settingCookieValue").prop('checked',false)
  else
    $("#revisitCookieValue").prop('checked',false)
    $("#settingCookieValue").prop('checked',true)
  
