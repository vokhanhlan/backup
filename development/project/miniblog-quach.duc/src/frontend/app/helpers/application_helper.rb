module ApplicationHelper
  # Return path (view or controller) of current page
  def current_path(type)
    case type
    when "controller"
      request.fullpath.split("?")[0]
    when "action"
      request.fullpath.split("/")[1]
    end
  end
end
