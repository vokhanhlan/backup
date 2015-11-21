rankings_element = $('#experienceContents')

# Reset infinite-scroll
# TODO: infinitescrollのresume、pauseの処理をまとめる
# ranking.js.coffeeの36行目でpauseしているので、ランキング入れ替えをしたときに再開させる処理
rankings_element.infinitescroll('resume')

# pageクエリが合った場合、pageクエリを削除する
if location.search.match(/[\?&]page=/)
  location.replace("/mypage")
else
  # Rendering ranking experiences
  rankings_element.html("<%= j(render partial: 'experiences/mini_panel_experience', collection: @experience_ranking, locals: { user_id: current_user.id }) %>")
InfiniteScroll.init()

# Rendering user information's background image
<% photo = main_photo(@experience_ranking.first, current_user) %>
userinfo_bg_img = $('.user-info__background')
userinfo_bg_img.html("<%= j(image_tag(photo.img(:normal), :'data-hidpi-src' => photo.img(:'normal@2x'))) %>")
