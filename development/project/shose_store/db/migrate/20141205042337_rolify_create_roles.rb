class RolifyCreateRoles < ActiveRecord::Migration
  def change
    create_table(:roles) do |t|
      t.string :name
      t.references :resource, :polymorphic => true

      t.timestamps
    end

    create_table(:nguoi_dungs_roles, :id => false) do |t|
      t.references :nguoi_dung
      t.references :role
    end

    add_index(:roles, :name)
    add_index(:roles, [ :name, :resource_type, :resource_id ])
    add_index(:nguoi_dungs_roles, [ :nguoi_dung_id, :role_id ])
  end
end
