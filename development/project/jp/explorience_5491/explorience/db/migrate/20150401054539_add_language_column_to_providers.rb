class AddLanguageColumnToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :language, :string, limit: 8, after: :nickname
  end
end
