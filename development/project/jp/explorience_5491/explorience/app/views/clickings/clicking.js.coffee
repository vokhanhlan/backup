# after clicking action
revisits = () ->
  clickings_go   = <%= @experience_clicking.clickings_find_by_user("go", current_user.id).present? %>
  clickings_went = <%= @experience_clicking.clickings_find_by_user("went", current_user.id).present? %>
  clickings_go && clickings_went

change_revisit_badge = () ->
  <% revisit_count = @experience_clicking.click_count(:revisit) %>
  target_experience = $('[data-experience=<%= @experience_clicking.id %>]' )
  icon_revisit = target_experience.find('.icon-revisit')
  revisit_badge_html = "<%= j (render partial: 'shared/revisit_badge', locals:{ revisits: revisit_count, specified: true })%>"
  if icon_revisit.size() == 0
    target_experience.find('.tag-block__scroll').before(revisit_badge_html)
    target_experience.find('.tag-block__scroll').addClass('transform-tag-scroll-width')
    target_experience.find('h1').after(revisit_badge_html)
  else
    target_experience.find('#revisitBadge').html(revisit_badge_html)
  revisit_badge_html.addEventListener()

change_revisit_btn = () ->
  <% revisit_count = @experience_clicking.click_count(:revisit) %>
  target_experience_revisit_btn = $('[data-experience_revisit=<%= @experience_clicking.id %>]' )
  target_experience_revisit_btn.find(".revisit-count-display").html("<%= revisit_count %>")


<% click_btn = @experience_clicking.clickings_find_by_user(@context, current_user.id).blank? ? "btn-block__btn-#{@context}" : "btn-block__btn-#{@context}--checked" %>

if "<%= @context %>" == "go"
  btn_go = $('#btnGo<%= @experience_clicking.id%>')
  btn_go.html("<%= j(render partial: 'clickings/button_go',
     locals: {experience: @experience_clicking, click_btn_go: click_btn}) %>")

if "<%= @context %>" == "went"
  btn_went = $('#btnWent<%= @experience_clicking.id%>')
  btn_went.html("<%= j(render partial: 'clickings/button_went',
    locals: {experience: @experience_clicking, click_btn_went: click_btn}) %>")
  $('#uploadModalBlock').show()

if revisits()
  $('#revisitModal').attr('id','clickRevisitModal')
  change_revisit_btn()
  # この順序で処理しないとモーダルとバッジが表示されない
  unless $.cookie('setting_going_again_modal') == 'hide'
    $("#clickRevisitModal").modal('show')
  change_revisit_badge()
