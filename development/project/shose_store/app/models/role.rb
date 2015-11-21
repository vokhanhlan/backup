class Role < ActiveRecord::Base
  has_and_belongs_to_many :nguoi_dungs, :join_table => :nguoi_dungs_roles
  belongs_to :resource, :polymorphic => true
  
  scopify
end
