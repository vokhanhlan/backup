# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  # maps起動URLの変更
  # iPhone/iPadの場合のみhrefが異なるためmaps:でURL指定
  if (navigator.userAgent.indexOf('iPhone') > 0) || (navigator.userAgent.indexOf('iPad') > 0)
    $('.openmap').each ->
      url = $(this).attr('href').replace('http://maps.google.com/maps?', 'maps:')
      $(this).attr('href', url)

  # 端末が縦か横かを判定、ボタンの表示を変える
  orientation_change = ->
    revisit_btn = $(".btn-block__revisit")
    go_btn = $(".btn-block__go")
    went_btn = $(".btn-block__went")
    $(window).on "load orientationchange", ->
      if window.innerHeight > window.innerWidth
        revisit_btn.hide()
        go_btn.addClass("btn--click").removeClass("btn--go")
        went_btn.addClass("btn--click").removeClass("btn--went")
      else
        revisit_btn.show().addClass("btn--revisit")
        go_btn.addClass("btn--go").removeClass("btn--click")
        went_btn.addClass("btn--went").removeClass("btn--click")
  orientation_change()

  # 再訪ボタンをクリックした時にモーダル表示
  $(document).on 'click', '.btn-block__revisit', () ->
    $("#revisitModal").modal('show')
    return false

  # 体験をクリックしたユーザーの表示制御
  # 詳しい動きが未定なので、開発側で暫定的に追加実装
  # TODO: 仕様FIX次第変更
  $(".count-block").click ->
    $(".user-block__clicking-user--part, .count-block").hide()
    $(".user-block__clicking-user--all").show()
  $(".close-btn").click ->
    $(".user-block__clicking-user--part, .count-block").show()
    $(".user-block__clicking-user--all").hide()

  # 体験詳細の「もっと見る」イベント
  $('.detail-block a').on 'click', ()->
    $('#collapseOne').collapse('toggle')

  sns_upload_modal = ()->
    if $("#snsUploadModal").length > 0
      $("#snsUploadModal").modal('show')
  sns_upload_modal()

  if $('#login').length == 0
    $('.uploaded-img').on 'click', (event) ->
      ajax_post(event.currentTarget)
  else
    $('.uploaded-img').on 'click', () ->
      src = $(this).children('img').attr('src')
      hidpi_src = src.replace('normal','normal@2x')
      img = $('.experience-photo-block img, .checked-experience__img img')
        .attr({'src': "#{src}", 'data-hidpi-src': "#{hidpi_src}"})
        .removeAttr('data-lowdpi-src')
        .get(0)
      RetinaTag.refreshImage(img)


  ajax_post = (element)->
    $.ajax({
      type: "post"
      url: element.dataset['url']
      data: {
        photo_id: element.dataset['photo_id'],
        experience_id: element.dataset['experience_id']
        }
      success: ()->
        console.log('Ajax POST was completed.')
        return false
      error: ()->
        console.log('Failed to Ajax POST.')
        return false
      })
