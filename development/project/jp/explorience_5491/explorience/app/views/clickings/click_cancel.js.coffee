<% click_btn = @experience_clicking.clickings_find_by_user(@context, current_user.id).blank? ? "btn-block__btn-#{@context}" : "btn-block__btn-#{@context}--checked" %>

if "<%= @context %>" == "go"
  btn_go = $('#btnGo<%= @experience_clicking.id%>')
  btn_go.html("<%= j(render partial: 'clickings/button_go', locals: {experience: @experience_clicking, click_btn_go: click_btn}) %>")
if "<%= @context %>" == "went"
  btn_went = $('#btnWent<%= @experience_clicking.id%>')
  btn_went.html("<%= j(render partial: 'clickings/button_went', locals: {experience: @experience_clicking, click_btn_went: click_btn}) %>")

<%= revisit_count = @experience_clicking.click_count(:revisit) %>
target_experience = $('[data-experience=<%= @experience_clicking.id %>]' )
target_experience_revisit_btn = $('[data-experience_revisit=<%= @experience_clicking.id %>]' )
if <%= revisit_count %> == 0
  target_experience.find(".icon-revisit").remove()
  target_experience.find('.tag-block__scroll').removeClass('transform-tag-scroll-width')
else
  target_experience.find(".icon-revisit .icon-revisit__count--box").html("<%= revisit_count %>")
  target_experience.find('.icon-revisit').removeClass('colored')

target_experience_revisit_btn.find(".revisit-count-display").html("<%= revisit_count %>")
