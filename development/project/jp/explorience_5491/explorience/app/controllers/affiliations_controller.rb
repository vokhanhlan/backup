class AffiliationsController < ApplicationController
  def create
    affiliation = Affiliation.new(affiliation_params)
    affiliation.user_id = nil if affiliation.user_id == 0
    affiliation.save!
    current_user.count_action(:refered_other_site) if current_user
    render nothing: true
  end

  private

  def affiliation_params
    params.permit(
      :experience_id,
      :user_id,
      :action_type
    )
  end
end
