module Localizable
  extend ActiveSupport::Concern

  included do
    before_action :restore_locale
  end

  # 表示言語を設定する
  def restore_locale
    I18n.locale = filtered_locale(auto_locale)
  end

  private
  def filtered_locale locale
    I18n.available_locales.find {|ok| locale.to_sym == ok } || I18n.default_locale
  end

  # アクセス時の状況から適当な言語設定を取得する
  # 優先される言語設定
  #   パラメータによる指定 > クッキーに保存された設定 > snsの言語設定情報(ログインしている場合) > HTTP_ACCEPT_LANGUAGEのデフォルト言語 > 英語
  # パラメータによる指定があった場合は, クッキーに設定を保存する
  # ログイン時でかつクッキーに値が設定されていない場合は, クッキーに設定を保存する
  def auto_locale
    if params[:locale]
      cookies[:locale] = params[:locale]
    elsif cookies[:locale].blank?
      cookies[:locale] = extract_locale_from_user_provider
    end

    cookies[:locale] || extract_locale_from_accept_language
  end

  # ログインしていればプロバイダーの言語設定を返す
  def extract_locale_from_user_provider
    if user_signed_in? && current_user.user_type != "curator"
      locale = current_user.providers.first.language
      convert_to_lang_code(locale)
    end
  end

  # requestの環境変数HTTP_ACCEPT_LANGUAGEからロケールを判定して返す
  # HTTP_ACCEPT_LANGUAGEが設定されていない場合は, デフォルトロケール(I18n.default_locale)を返す
  def extract_locale_from_accept_language
    if request.env['HTTP_ACCEPT_LANGUAGE'].present?
      locale = request.env['HTTP_ACCEPT_LANGUAGE']
      lang_code = convert_to_lang_code(locale)
    else
      I18n.default_locale
    end
  end

  # ロケール文字列から言語コードを判定
  # 言語コードは, 与えられた文字列の先頭2文字によって得られると想定
  # @param  [String] locale ロケール文字列
  # @return [String] 引数に含まれる言語-国コードのみを抜き出して返却
  def convert_to_lang_code locale
    locale[0,2]
  end
end
