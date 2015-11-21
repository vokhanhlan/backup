# Configulations for ActsAsTaggableOn
# example:
# ActsAsTaggableOn.delimiter = '|'

# for globalize and globalize-accessors
ActsAsTaggableOn::Tag.class_eval do
  translates :name
  globalize_accessors locales: [:en, :ja, :ko, :th], attributes: [:name]

  after_save :update_name_column

  private

  # NOTE: globalize 5.0.1でtag_translationsに存在するnameカラムをinsertしない挙動に変更されたため手動更新
  def update_name_column
    name = self.name_ja
    args = ['UPDATE tags SET name = ? WHERE id = ?', name, self.id]
    sql = ActiveRecord::Base.__send__(:sanitize_sql_array, args)
    ActiveRecord::Base.connection.execute(sql)
  end
end
