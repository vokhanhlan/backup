class GuidesController < ApplicationController
  def index
    @guides = Guide.order(section: :asc)
    current_user.count_action(:refered_menu_guide) if current_user
  end
end
