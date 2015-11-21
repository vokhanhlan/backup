ActiveAdmin.register Experience do
  #管理画面タイトル設定
  menu priority: 2, label: "Experiences"

  #表示項目
  index do
    selectable_column
    id_column
    column :image do |exp|
      image_tag exp.photos.first.img.url(:normal) if exp.photos.present?
    end
    column :advertiser
    column :title
    column :description
    column :address
    column :workday
    column :start_date
    column :end_date
    column :tel
    column :price
    column :url
    actions
  end

  #検索項目
  filter :advertiser
  filter :translations_title, :as => :string
  filter :translations_description, :as => :string
  filter :translations_address, :as => :string
  filter :translations_workday, :as => :string
  filter :end_date
  filter :tel
  filter :price
  filter :url

  #入力項目
  form :html => { :enctype => "multipart/form-data" } do |f|
    hint_image = (f.object.new_record? || f.object.photos.empty?)? "" : f.image_tag(f.object.photos.first.img.url(:normal))
    f.inputs do
      f.input :advertiser_id,
        hint: '(任意) 本コンテンツを広告として登録する場合、広告主の情報を事前にAdvertiserに登録の上、 割り振られたID(advertiser_id)を入力してください'
      f.input :start_date, as: :datepicker,
        hint: '(任意) 本コンテンツを広告として登録する場合に入力してください'
      f.input :end_date, as: :datepicker,
        hint: '(任意) 本コンテンツを広告として登録する場合に入力してください。無入力の場合、またはこの項目の期日が過ぎた場合、本コンテンツは表示されなくなります'
      f.input :title_ja
      f.input :description_ja, as: :text
      f.input :address_ja
      f.input :workday_ja
      (I18n.available_locales - [:ja]).each do |locale|
        f.input "title_#{locale}".to_sym
        f.input "description_#{locale}".to_sym, as: :text
        f.input "address_#{locale}".to_sym
        f.input "workday_#{locale}".to_sym
      end
      f.input :tel
      f.input :price
      f.input :url
      f.input :prefecture_list, label: "Prefecture tags ja",
        input_html: { value: f.object.prefecture_list.to_s.gsub(/, /, ',') }
      f.input :genre_list, label: "Genre tags ja",
        input_html: { value: f.object.genre_list.to_s.gsub(/, /, ',') }
      f.input :img, as: :file, hint: hint_image
      f.has_many :experience_photos do |b|
        b.input :photo_id
      end
    end
    # TODO HACK: Create Experienceボタン、取り消しボタンをpartial化
    ## 背景
    # actionsに属性を付与する方法について調査したが解決方法見つからず、
    # 現状、active_admin_experience.js.coffee内で、submitボタンにdata-disable-with属性を追加して対応
    f.actions
  end

  controller do
    def create
      ActiveRecord::Base.transaction do
        @experience = Experience.new
        set_input_params(@experience)
        exp_photo_attrs = params[:experience][:experience_photos_attributes]
        if exp_photo_attrs && exp_photo_attrs["0"][:photo_id].present?
          @experience.experience_photos.create(photo_id: exp_photo_attrs["0"][:photo_id])
        else
          @experience.photos.create!(img: params[:experience][:img])
        end
        flash[:notice] = "Succeeded to create experience"
        redirect_to admin_experiences_path
      end
    rescue Exception => e
      flash[:error] = "Failed to create experience. #{e.message}"
      render action: "new"
    end

    def update
      ActiveRecord::Base.transaction do
        @experience = Experience.find_by(id: params[:id])
        set_input_params(@experience)
        if params[:experience][:img].nil?
          exp_photo_attrs = params[:experience][:experience_photos_attributes]
          if exp_photo_attrs && exp_photo_attrs["0"][:photo_id].present?
            exp_photo = ExperiencePhoto.find_or_initialize_by(experience_id: @experience.id)
            exp_photo.photo_id = exp_photo_attrs["0"][:photo_id]
            exp_photo.save! unless exp_photo.photo_id == exp_photo.photo_id_was
          end
        else
          if @experience.photos.present?
            photo = @experience.photos.first
            photo.update_attributes(img: params[:experience][:img])
          else
            @experience.photos.create!(img: params[:experience][:img])
          end
        end
        flash[:notice] = "Succeeded to update experience"
        redirect_to admin_experiences_path
      end
    rescue Exception => e
      flash[:error] = "Failed to update experience. #{e.message}"
      render action: "edit"
    end

    def set_input_params(exp)
      I18n.available_locales.each do |loc|
        Globalize.with_locale(loc) do
          # 未入力時は""が渡され、そのままsaveするとfallbackできないため
          # 該当データが""の場合はnilをセットする
          title       = params[:experience][:"title_#{loc}"]
          description = params[:experience][:"description_#{loc}"]
          address     = params[:experience][:"address_#{loc}"]
          workday     = params[:experience][:"workday_#{loc}"]
          exp.title       = (title.present?)?       title       : nil
          exp.description = (description.present?)? description : nil
          exp.address     = (address.present?)?     address     : nil
          exp.workday     = (workday.present?)?     workday     : nil
        end
      end
      exp.advertiser_id = params[:experience][:advertiser_id]
      exp.start_date    = params[:experience][:start_date]
      exp.end_date      = params[:experience][:end_date]
      exp.tel   =  params[:experience][:tel]
      exp.price =  params[:experience][:price]
      exp.url   =  params[:experience][:url]
      # :prefectures, :genresは*_enという参照ができない(というかない)ので、
      # ここでは:jaロケール固定で登録をする
      Globalize.with_locale(:ja) do
        exp.set_tag_list_on(:prefectures, params[:experience][:prefecture_list])
        exp.set_tag_list_on(:genres, params[:experience][:genre_list])
        exp.save!
      end
    end
  end

  # TODO HACK: 未使用であれば適切にstrong parameter使用するか削除する
  parameter_names = [
    :advertizer_id,
    :start_date,
    :end_date,
    :tel,
    :price,
    :url,
    :img,
    :prefectures,
    :genres
  ]
  I18n.available_locales.each do |locale|
    parameter_names << :"title_#{locale}"
    parameter_names << :"description_#{locale}"
    parameter_names << :"address_#{locale}"
    parameter_names << :"workday_#{locale}"
  end
  permit_params parameter_names

  #show画面、表示項目
  show do |experience|
    panel "#{experience.id}" do
      attributes_table_for experience, :advertiser, :title, :description, :address, :workday, :start_date, :end_date, :tel, :price, :url
      attributes_table_for experience do
        row :prefectures do
          Experience.find_by(id: experience.id).prefecture_list
        end
        row :genres do
          Experience.find_by(id: experience.id).genre_list
        end
      end
      attributes_table_for experience do
        row :item_image do
          image_tag(experience.photos.first.img.url(:normal)) unless experience.photos.empty?
        end
      end
    end
  end

  #
  # csv import
  #
  # NOTE: 期待するCSVファイルのフォーマットについて
  #   以下のExperienceカラム名を1行目に記入（順不同）
  #     :advertiser_id(任意), :tel, :url, :start_date, :end_date
  #   加えて、Experienceモデル以外のカラム名を同じく1行目に記入（順不同）
  #     :prefecture_ja, :prefecture_en, :genres_ja, :genres_en (for tags, tag_translations)
  #     :title_ja, :description_ja, :address_ja, :workday_ja   (for experience_translations)
  #     :title_en, :description_en, :address_en, :workday_en   (for experience_translations)
  #     # add: 20150525 韓国語対応
  #     :title_ko, :description_ko, :address_ko, :workday_ko   (for experience_translations)
  #     # add: 20150609 タイ語対応
  #     :title_th, :description_th, :address_th, :workday_th   (for experience_translations)
  #     :photo_id (for photos, experience_photos)
  #   2行目移行にimportするデータを入力
  #

  # TODO HACK: 言語依存の変数名を定義して処理しているため、I18n.available_localesに依存して処理できるようリファクタする

  active_admin_importable do |model, hash|
    # 同titleの体験コンテンツがない場合に保存
    # TODO: 下記制御(search_title)の6ヶ国語対応したときの落とし所を調整, とりあえずこのまま(修正しない)
    #       1. 日本語が入ってる前提として,以下だけ
    #          search_title = hash[:title_ja]
    #       2. 6ヶ国考慮したタイトルチェックをする
    #          if hash[:title_ja]
    #            search_title = hash[:title_ja]
    #          elsif hash[:title_en]
    #            search_title = hash[:title_en]
    #          :
    #          :
    search_title = (hash[:title_ja])? hash[:title_ja] : hash[:title_en]
    # TODO HACK: model.exists?で検索するようにできないか？
    #   model.exists?だとvalidationに付けているtitle,descriptionがnullでないレコードを
    #   検索しに行くため、descriptionがnullなレコードにhitしない。
    #   そのため、暫定的にwhereで検索をしている
    if search_title && model.joins(:translations).where(experience_translations: {title: search_title}).empty?
      ActiveRecord::Base.transaction do
        exp = model.new

        # NOTE: ASCII-8BITのままsaveするとvalidationに失敗するためUTF-8に変更
        hash.each do |key, val|
          val.force_encoding('UTF-8') if val
        end

        # 体験コンテンツのカラム情報セット
        I18n.available_locales.each do |loc|
          Globalize.with_locale(loc) do
            exp.title       = hash[:"title_#{loc}"]
            exp.description = hash[:"description_#{loc}"]
            exp.address     = hash[:"address_#{loc}"]
            exp.workday     = hash[:"workday_#{loc}"]
          end
        end
        exp.tel   = hash[:tel]
        exp.price = hash[:price]
        exp.url   = hash[:url]

        exp.advertiser_id = hash[:advertiser_id]
        exp.start_date    = Time.zone.parse(hash[:start_date]) if hash[:start_date]
        exp.end_date      = Time.zone.parse(hash[:end_date])   if hash[:end_date]

        # tag登録および体験コンテンツの保存
        Globalize.with_locale(:ja) do
          exp.set_tag_list_on(:prefectures, hash[:prefecture_ja])
          exp.set_tag_list_on(:genres, hash[:genres_ja])
          exp.save!
        end

        # tagの外国語データ更新
        tags_ja = "#{hash[:prefecture_ja]},#{hash[:genres_ja]}".split(',')
        tags_en = "#{hash[:prefecture_en]},#{hash[:genres_en]}".split(',')
        tags_ko = "#{hash[:prefecture_ko]},#{hash[:genres_ko]}".split(',')
        tags_th = "#{hash[:prefecture_th]},#{hash[:genres_th]}".split(',')

        tags_ja.each_with_index do |tag_ja, i|
          # 指定tagのenレコードがない場合に保存
          (I18n.available_locales - [:ja]).each do |loc|
            unless ActsAsTaggableOn::Tag.joins(:translations)
                .exists?(tags: { name: tag_ja }, tag_translations: { locale: loc })
              if eval("tags_#{loc}[i]").present?
                translation = ActsAsTaggableOn::Tag.joins(:translations).find_by(name: tag_ja).translations.new
                translation.locale = loc
                translation.name = eval("tags_#{loc}[i]")
                translation.save!
              end
            end
          end
        end

        # 画像データとの紐付け
        # NOTE: 有効な画像IDが無い場合はexp.title_jaをファイル名に含む画像を検索。見つからなければデフォルト画像登録
        photo_id = hash[:photo_id].to_i
        unless Photo.exists?(id: photo_id)
          photo = Photo.find_by(img_file_name: hash[:photo_file_name])
          unless photo
            default_image = File.new("#{Rails.root}/public/missing.jpg")
            photo = Photo.create(img: default_image)
          end
          photo_id = photo.id
        end
        ExperiencePhoto.create!(experience_id: exp.id, photo_id: photo_id)
      end
    end
  end
end
