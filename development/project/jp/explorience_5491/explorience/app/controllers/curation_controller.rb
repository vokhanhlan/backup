class CurationController < ApplicationController
  before_action :curator_access_revoke
  before_action :set_curation_experience, only: [:show, :edit, :update]
  before_action :set_default_language

  # TODO: show message and info use curation after sign in
  def dashboard

  end

  # TODO: View list experiences
  def index

  end

  # TODO: Show detail a experiences
  def show

  end

  # TODO: Create a experience empty
  def new

  end

  # TODO: Modify a experience
  def edit

  end

  # TODO: Create a experience and save into database
  def create

  end

  # TODO: Changed info a experience
  def update

  end

private
  # TODO: Find a experience by id
  def set_curation_experience

  end

  # TODO: Get params a experience when create and submit
  def curation_experience_params

  end

  # TODO: Set language default ja
  def set_default_language
    I18n.locale = :ja
  end

  # Redirect to root_path if user not yet login or don't user curator
  def curator_access_revoke
    unless user_signed_in? && current_user.user_type == "curator"
      redirect_to root_path
    end
  end
end
