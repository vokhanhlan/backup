module ApplicationHelper

  # 並び替え用popoverのdata-contentに展開するHTML生成
  def sorting_component( path='/', type=nil )
    base_button_class = 'btn btn-default'
    if type == 'by_evaluation'
        class_posted     = base_button_class
        class_evaluation = "#{base_button_class} disabled"
    else
        class_posted     = "#{base_button_class} disabled"
        class_evaluation = base_button_class
    end
    title = t 'helpers.application_helper.sorting_component.title'
    posted_order_button = button_to t('helpers.application_helper.sorting_component.by_posted'),
      path, params: { sort: 'by_posted' }, method: :get, class: class_posted
    evaluation_order_button = button_to t('helpers.application_helper.sorting_component.by_evaluation'),
      path, params: { sort: 'by_evaluation' }, method: :get, class: class_evaluation
    "<div class='popover_sort_content'>#{title}#{posted_order_button}#{evaluation_order_button}</div>"
  end

  # query文字列からパラメータを除く
  # @param [String] uri URI
  # @param [Array<String>] keys 除きたいパラメータのキー文字列群
  # @return [String] 作成されたURI
  def remove_query uri, *keys
    _uri, _query = uri.split('?')
    return uri if keys.blank? || _query.nil?

    u = URI.parse(_uri)
    params = Rack::Utils.parse_nested_query(Rack::Utils.unescape(_query.to_s))
    if params.present?
      keys.each{ |key|  params.delete(key.to_s) }
      u.query = Rack::Utils.build_nested_query(params).presence
    end

    u.to_s
  rescue URI::InvalidURIError
    return uri
  end

  # menuページでの人気のタグ取得
  #   タグが付与されている複数体験について1体験あたりのscore平均値を取り、
  #   上位10件のTagオブジェクトを抽出
  # TODO HACK: joinsで複数テーブルの結合をもっと簡潔に書きたい
  # TODO HACK: .joins.eager_loadでINNER JOINなeager loadingしたかったが、複数テーブル結合時の方法がわからず。
  #   現状はselectでtaggings.contextもロードしておくようにしている
  def popular_tags
    ActsAsTaggableOn::Tag
      .joins(:translations)
      .joins("INNER JOIN taggings ON tags.id = taggings.tag_id INNER JOIN experiences ON taggings.taggable_id = experiences.id")
      .where(tag_translations: {locale: I18n.locale})
      .group("tags.id")
      .order("SUM(experiences.score)/tags.taggings_count DESC")
      .select("tags.*, taggings.context AS taggings_context, tag_translations.name AS translations_name")
      .limit(10)
  end

  # menuページでの地名のタグ取得
  def prefecture_tags
    ActsAsTaggableOn::Tag
      .eager_load(:translations, :taggings)
      .where(taggings: {context: "prefectures"}, tag_translations: {locale: I18n.locale})
      .group("tags.name")
      .order("tag_translations.name ASC")
  end

  def default_meta_tags
    {
      description: t("common.site.page_description"),
    }
  end

  def experience_title_path(experience)
    "#{experience_path(experience.id)}-#{experience.title}"
  end
end
