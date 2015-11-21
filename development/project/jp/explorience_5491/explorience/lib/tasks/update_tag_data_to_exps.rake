# TODO HACK: 時間の関係上ベタ書きしています。要リファクタ。
require 'csv'

namespace :experience do
  @csv_file = 'db/experience_data_additional/20150422_repair_tags_for_0001-1013.csv'
  @log_file = 'log/rake_update_tag_data_to_exps.log'
  @count_of_update_ja_genre_list = 0
  @count_of_update_en_genre_name = 0
  @count_of_exchange_ja_genre = 0
  @count_of_create_new_en_genre = 0

  desc "Update genre tags to existing experiences."
  task update_genre_tags: :environment do
    # genre_list参照がGloablize.with_locale効かないため:jaで処理する
    I18n.locale = :ja
    @logger = Logger.new(@log_file)
    puts "Proecess log output to #{@log_file}".yellow
    puts "Load CSV from #{@csv_file}\n".yellow
    hashes = load_csv
    puts "Check genre tags format.".yellow
    validate_format_of_genres(hashes)
    puts "Update genre tags to existing experiences.".yellow
    update_tags(hashes)
    puts "\nUpdate genre tags was succeed.".green
    output_result
  end

  def load_csv
    csv_file_path = Rails.root.join(@csv_file)

    puts "Generate hash list for Tag table.".yellow
    puts "  #{@csv_file} reading..."

    keys   = []
    hashes = []
    CSV.foreach(@csv_file, 'r') do |row|
      if keys.empty?
        row.each do |column|
          column.slice!(0) if column[0] == ':'
          keys << column
        end
      else
        hash = {}
        keys.each_with_index { |key, i| hash[key.to_sym] = row[i] }
        hashes << hash
      end
    end
    puts "CSV file reading was done.\n".green
    hashes
  end

  def validate_format_of_genres(hashes)
    hashes.each do |hash|
      if "#{hash[:genres_ja]},#{hash[:genres_en]}".index(', ')
        raise "Illegal separeter ', ' using at genres. ja: #{hash[:genres_ja]}, en: #{hash[:genres_en]}".red
      elsif hash[:genres_ja].split(',').size != hash[:genres_en].split(',').size
        raise "Different size of genres. ja: #{hash[:genres_ja]}, en: #{hash[:genres_en]}".red
      end
    end
    puts "...There are safe genre tags.\n".green
  end

  def output_info(str, opt={})
    @logger.info str
    (opt[:color])? print("  #{str}".__send__(opt[:color].to_sym)) : print("  #{str}")
    puts "\n" if opt[:with_return_code]
  end

  def output_result
    output_info('Result...', with_return_code: true)
    output_info("  Count of updaete ja genre list: #{@count_of_update_ja_genre_list}", with_return_code: true)
    output_info("  Count of updaete en genre name: #{@count_of_update_en_genre_name}", with_return_code: true)
    output_info("  Count of exchange ja genre tag: #{@count_of_exchange_ja_genre}",    with_return_code: true)
    output_info("  Count of create new en genre  : #{@count_of_create_new_en_genre}",  with_return_code: true)
  end

  def update_tags(hashes)
    puts "Update Experience and Tag table.".yellow
    hashes.each do |hash|
      exp = Experience.find_by(title: hash[:title_ja])
      next if exp.nil? || exp.genre_list == hash[:title_ja]

      ActiveRecord::Base.transaction do
        # tag登録および体験コンテンツの保存
        unless exp.genre_list.join(',') == hash[:genres_ja]
          Globalize.with_locale(:ja) do
            output_info "Try to update '#{exp.title_ja}' tag(ja): from '#{exp.genre_list}', to '#{hash[:genres_ja]}'"
            exp.set_tag_list_on(:genres, hash[:genres_ja])
            exp.save!
            puts '...done!'.green
            @count_of_update_ja_genre_list += 1
          end
        end

        # 登録tag情報の分割
        tags_ja = hash[:genres_ja].split(',')
        tags_en = hash[:genres_en].split(',')

        # 各tagの英訳データ更新
        tags_ja.each_with_index do |tag_ja, i|
          # 英訳データチェック
          if tags_en[i].nil? || tags_en[i].empty?
            raise "Empty English tag name detected: '#{tag_ja}', process exit."
          end

          # 英訳データを持つtagの取得
          current_tag = ActsAsTaggableOn::Tag.joins(:translations)
                          .find_by(tags: { name: tag_ja }, tag_translations: { locale: :en })
          # 保存しようとしている英訳データを持つ、別tagの取得
          another_tag = ActsAsTaggableOn::Tag.joins(:translations)
                          .where(tag_translations: { name: tags_en[i], locale: :en })
                          .where.not(tags: { name: tag_ja })
                          .take

          if current_tag
            if another_tag
              if another_tag.name_en.present?
                # 現状のtag_jaを削除し、検出した別tagの和訳に、現在のexpの和訳データをセット
                Globalize.with_locale(:ja) do
                  output_info "Try to exchange tag for '#{exp.title_ja}' : from '#{tag_ja}', to '#{another_tag.name_ja}'", color: 'red'
                  exp.genre_list.remove(tag_ja)
                  exp.genre_list.add(another_tag.name_ja)
                  exp.save!
                  puts '...done!'.green
                  @count_of_exchange_ja_genre += 1
                end
              else
                raise "Untranslated another tag detected: '#{another_tag.name_ja}', process exit."
              end
            else
              # 英訳データ更新
              unless current_tag.name_en == tags_en[i]
                output_info "Try to update tag.name_en of '#{tag_ja}': from '#{current_tag.name_en}', to '#{tags_en[i]}'"
                Globalize.with_locale(:ja) do
                  current_tag.name_en = tags_en[i]
                  current_tag.save!
                end
                puts '...done!'.green
                @count_of_update_en_genre_name += 1
              end
            end
          else
            # 保存しようとしている英訳データを持つ、別tagの取得
            if another_tag
              if another_tag.name_en.present?
                # 現状のtag_jaを削除し、検出した別tagの和訳に、現在のexpの和訳データをセット
                Globalize.with_locale(:ja) do
                  output_info "Try to exchange tag for '#{exp.title_ja}' : from '#{tag_ja}', to '#{another_tag.name_ja}'", color: 'red'
                  exp.genre_list.remove(tag_ja)
                  exp.genre_list.add(another_tag.name_ja)
                  exp.save!
                  puts '...done!'.green
                  @count_of_exchange_ja_genre += 1
                end
              else
                raise "Untranslated another tag detected: '#{another_tag.name_ja}', process exit."
              end
            else
              # 英訳データ新規作成
              output_info "Try to create tag.name_en of '#{tag_ja}': to '#{tags_en[i]}'", color: 'yellow'
              translation = ActsAsTaggableOn::Tag.find_by(name: tag_ja).translations.new
              translation.locale = :en
              translation.name = tags_en[i]
              translation.save!
              puts '...done!'.green
              @count_of_create_new_en_genre += 1
            end
          end
        end
      end
    end
  end
end
