require 'csv'

namespace :experience do
  desc "Add English data to existing experiences."
  task update_en_data: :environment do
    begin
      puts "Update English data to existing experiences and tags.".yellow
      Globalize.with_locale(:en) { update_experiences }
      puts "\nUpdate English data was succeed.".green
    rescue => ex
      puts ex.inspect.red
      puts "\nFailed to update English data to existing experiences and tags.".red
    end
  end

  @csv_files_dir = 'db/experience_data_additional'

  # TODO: 最終的なCSVファイルフォーマットに合わせ込むこと
  # CSV format:
  #   ja: 0:Title,  1:Tag(Pref.),  2:Addr,  3:Desc.,  4:WorkDay,  5:TEL, 6:URL, 7:PhotoURL, 8:Tag(Genre)
  #   en: 9:Title, 10:Tag(Pref.), 11:Addr, 12:Desc., 13:WorkDay, 14:Tag(Genre)
  def update_experiences
    csv_files.each do |target_file|
      exp_translations = []
      tag_translations = []

      csv_file_path = Rails.root.join(@csv_files_dir,target_file)

      puts "Generate translation list for Experience and Tag table.".yellow
      puts "#{csv_file_path} reading..."

      CSV.foreach(csv_file_path, 'r') do |row|
        # skip row of column titles
        next if row.first == "観光地名"
        exp_translations = update_experience(exp_translations, row)
        tag_translations = update_tag(tag_translations, row[1], row[10])
        tag_translations = update_tag(tag_translations, row[8], row[14])
      end

      puts "CSV file reading was done.\n\n"

      if exp_translations.empty? && tag_translations.empty?
        puts "No update target. Updating was stopped.".yellow
      else
        puts "Bulk-insert to Experience and Tag table...".yellow
        ActiveRecord::Base.transaction do
          Experience::Translation.import exp_translations unless exp_translations.empty?
          ActsAsTaggableOn::Tag::Translation.import tag_translations unless tag_translations.empty?
        end
        puts "Bulk-insert was finished!!".yellow
      end
    end
  rescue => ex
    puts ex.message
    puts "Program has canceled the commit of this CSV file.".red
    raise
  end

  # CSVファイル格納ディレクトリ内のファイルリスト取得
  # NOTE: 対象ディレクトリに格納されているcsvファイルは全て読み込むので注意
  def csv_files
    stored_files = Dir::entries(Rails.root.join(@csv_files_dir))
    # ファイルリストから、拡張子が.csv以外のものを削除
    stored_files.delete_if { |item| item !~ /\A.+\.csv\z/ }
    puts "\nStored files:".yellow
    puts stored_files
    puts ""
    return stored_files
  end

  # TODO HACK: 可能ならクエリをまとめる（良案浮かばず）
  def update_experience(translations, row)
    exp = Experience.find_by(title: row[0])
    translation = exp.translations.find_by(locale: Globalize.locale)
    unless translation
      translation = exp.translations.new
      translation.locale = Globalize.locale
    end
    translation.title       = row[9]
    translation.description = row[12]
    translation.address     = row[11]
    translation.workday     = row[13]
    if translation.changed?
      translations << translation
      puts "  set: Experience: ID=#{exp.id}, #{exp.title_ja} -> #{translation.title}"
    end
    return translations
  end

  # TODO HACK: 可能ならクエリをまとめる（良案浮かばず）
  def update_tag(translations, target_name, update_name)
    tag = ActsAsTaggableOn::Tag.find_by(name: target_name)
    translation = tag.translations.find_by(locale: Globalize.locale)
    unless translation
      translation = tag.translations.new
      translation.locale = Globalize.locale
    end
    unless translations.any? { |item| item.name == update_name }
      translation.name = update_name
      if translation.changed?
        translations << translation
        puts "  set: Tag       : ID=#{tag.id}, #{tag.name_ja} -> #{translation.name}".green
      end
    end
    return translations
  end
end
