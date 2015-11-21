follow = $('.follow-btn-block')
<% follow_btn_class = @following.present? ? '' : 'followed' %>
follow.html("<%= j(render partial: 'follows/follow_btn',locals: {follow_btn_class: follow_btn_class, following_id: @following_id}) %>")
$(".follower-count").html("<%= @follower_count %>")

follow_list = $("#followBtn<%= @following_id %>")
follow_list.html("<%= j(render partial: 'follows/follow_btn', locals: {follow_btn_class: follow_btn_class, following_id: @following_id}) %>")


