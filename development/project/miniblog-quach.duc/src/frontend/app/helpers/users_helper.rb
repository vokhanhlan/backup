module UsersHelper
  # Render edit form need
  def render_view_edit(f)
    case current_path("action")
    when "edit_user_info"
      render :partial => 'users/form/form_edit_info', locals: {f:f}
    when "edit_user_pass"
      render :partial => 'users/form/form_change_pass', locals: {f:f}
    else
      render :partial => 'users/form/form_edit_info', locals: {f:f}
    end
  end
end
