$ ->
  # TODO: topだけじゃなく、mypageでも使用するため、適切な場所に移動
  # maps起動URLの変更
  # iPhone/iPadの場合のみhrefが異なるためmaps:でURL指定
  if (navigator.userAgent.indexOf('iPhone') > 0) || (navigator.userAgent.indexOf('iPad') > 0)
    $('.openmap').each ->
      url = $(this).attr('href').replace('http://maps.google.com/maps?', 'maps:')
      $(this).attr('href', url)
  
  # ヘッダーの足跡アイコンをトップページのみで表示
  unless $("#topPage").length > 0
    $(".icon-block img").hide()
  # ポップオーバー表示
  $('[data-toggle=popover]').popover({html: true})
  # ポップオーバー非表示(popover要素以外がクリックされたらhide)
  $(document).on "click touchstart", (e) ->
    if $('.popover-content').length > 0 &&
      !$.contains($('.popover')[0], e.target) &&
      !$.contains($('[data-toggle=popover]')[0], e.target)
        $('[data-toggle=popover]').popover('hide')

  # ログインモーダル
  if $('#login').length > 0
    # TODO HACK: 未ログインユーザーでタグ検索した場合、ログインモーダル出さないようにする対処。要リファクタ
    if $('#topPage').length > 0 &&
       $('#reportCompleted').length == 0 &&
       $('#errorModal').length == 0 &&
       $('#loginModalDisable').length == 0
      $('#login').modal('show')
    side_menu_login()
    btn_action_before_login()

  # ログイン失敗モーダル
  if $('#loginError').length > 0
    $('#loginError').modal('show')


  # infinitescroll
  InfiniteScroll.init()

  # タブの切替時にinfinite scrollを一時停止もしくは再起動する処理
  $('li a[href="#tabPanelPhotos"]').on 'click', ()->
    $('#experienceContents').infinitescroll('pause')
    $('#tabPanelPhotos').infinitescroll('resume')
    $('#tabPanelPhotos').infinitescroll('bind')
    InfiniteScroll.initForUploadedPhoto()
  $('li a[href="#tabPanelExperiences"]').on 'click', ()->
    $('#tabPanelPhotos').infinitescroll('pause')
    $('#experienceContents').infinitescroll('resume')
    $('#experienceContents').infinitescroll('bind')

  $("#menu").mmenu({
    slidingSubmenus: false
  })

  # リダイレクト時にMypageの指定されたタブを表示する
  if (document.location.hash) == "#tabPanelBadge"
    $(".nav-tabs a[href='#tabPanelBadge']").tab('show')

btn_action_before_login = ()->
  $(document).on 'click', '.btn-block__btn-go , .btn-block__btn-went', ()->
    $('#login').modal('show')

# btn_action_before_login()で一緒に処理を行おうとしたが、
# うまく動作しなかったので、サイドメニューのログインを別途切り出す
# TODO: ログインモーダル部分を共通化したい
side_menu_login = ()->
  $('.login').on 'click touchstart', ()->
    $("nav#menu").data('mmenu').close()
    $('#login').modal('show')
