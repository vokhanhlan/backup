ActiveAdmin.register Affiliation do
  menu priority: 11

  config.clear_action_items!
  # TODO HACK: Requestからqueryを取り出す方法が下記方法以外にわからない
  filter :experience, as: :select, collection: proc {
    options_from_collection_for_select(
      Experience.all, :id, :title,
      (@_request.filtered_parameters['q'])? @_request.filtered_parameters['q']['experience_id_eq'] : nil
    )
  }
  filter :action_type, as: :select, collection: Affiliation.action_types
  filter :created_at
end
