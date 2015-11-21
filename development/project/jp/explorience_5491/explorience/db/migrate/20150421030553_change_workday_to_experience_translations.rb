class ChangeWorkdayToExperienceTranslations < ActiveRecord::Migration
  def up
    change_column :experience_translations, :workday, :text
  end

  def down
    change_column :experience_translations, :workday, :string
  end
end
