class ChangeColumnNullInExperienceTranslations < ActiveRecord::Migration
  def change
    change_column_null :experience_translations, :title, true
    change_column_null :experience_translations, :description, true
  end
end
