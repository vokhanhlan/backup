# Rendering lock icon
ranking_element = $('#experience<%= @ranking.experience.id %>')
ranking_element.html("<%= j(render partial: 'experiences/rank', locals: {ranking: @ranking}) %>")

# Add/Remove un-draggable class selector for sortable
<% if @ranking.locked %>
ranking_element.parents('.experience--mini-panel').addClass('undraggable')
<% else %>
ranking_element.parents('.experience--mini-panel').removeClass('undraggable')
<% end %>
