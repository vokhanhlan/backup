class Users::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(resource)
    curation_experience_dashboard_path
  end
end
