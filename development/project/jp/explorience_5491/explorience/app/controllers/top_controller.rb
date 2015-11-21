class TopController < ApplicationController
  include Scorable

  before_action :authenticate_user!,    :except => [:show, :set_locale, :privacy_policy, :add_tag_filter, :remove_tag_filter]
  before_action :set_context_filter,    :except => [:mypage]
  before_action :set_sort_type,         :only   => [:show, :mypage]
  before_action :update_context_filter, :only   => [:mypage]
  before_action :set_tag_names
  before_action :set_context_filter,    :except => [:mypage]
  before_action :add_bonus_for_login,   :only   => [:show, :mypage]
  before_action :signout_if_curator

  def show
    @unauthenticated = params[:unauthenticated]
    # TODO HACK: 未ログインユーザーでタグ検索した場合、ログインモーダル出さないようにする対処。要リファクタ
    @login_modal_disable = flash[:login_modal_disable]

    # TODO HACK: 再訪体験絞り込み時に正しく体験一覧が取得できなかったため暫定対処
    filter_by_tag = Experience.filter_by_tag(Experience.all, @tag_names)
    filter_by_tag = filter_by_tag.with_photos unless @context_filter == 'revisit'

    #「行きたい」「行った」「再訪したい」の絞り込み
    if @context_filter
      filter_by_tag = filter_by_tag.filter_by_click_context(@context_filter, current_user)
    end

    @all_prefecture_tags = select_tag_names('prefectures', Experience.all).uniq
    @all_genre_tags = select_tag_names('genres', Experience.all).uniq

    # 個別タグの紹介エリア
    # TODO: ver2.0リリースに向け、一時的に機能マスク
    # @prefecture_tag_name = ActsAsTaggableOn::Tag.eager_load(:taggings, :translations)
    #                                             .where(id: @tags.ids,
    #                                                    taggings: {context: 'prefectures'},
    #                                                    tag_translations: {locale: I18n.locale}).first.try(:name)

    # sorting for experiences
    if @sort_type.nil? || @sort_type == 'by_posted'
      ad_contents = filter_by_tag.ad_contents.publishable
      @ad_experiences = ad_contents.posted_order
                                   .page(params[:page])
                                   .per(Constants::counts_per_page_for_ad)
      @experiences    = filter_by_tag.regular_contents.posted_order
      session.delete(:sort)
    else
      ad_contents     = Experience.none
      @ad_experiences = ad_contents
      @experiences    = filter_by_tag.evaluation_order
      session[:sort] = params[:sort]
    end

    page, cpp, padding = calc_adjust_pagination_params(@ad_experiences, ad_contents.count)

    @experiences = @experiences.page(page)
                               .per(cpp)
                               .padding(-padding)
    # sort button path
    @sort_path = root_path
  end

  def mypage
    # user profiles
    @user = current_user
    @user_name             = current_user.providers.first.nickname
    @user_image            = current_user.providers.first.photo_url
    @clicked_count_revisit = current_user.click_count(:revisit)
    @clicked_count_go      = current_user.click_count(:go)
    @clicked_count_went    = current_user.click_count(:went)

    # filtering and sorting for clicked experiences
    clicked_experiences_filter_by_context = Experience.filter_by_click_context(@context_filter, current_user)
    # TODO: ver2.0リリースに向け、一時的に機能マスク
    #filtered_experiences = Experience.filter_by_tag(clicked_experiences_filter_by_context, @tag_names)
    filtered_experiences = clicked_experiences_filter_by_context
    # TODO HACK: 再訪体験絞り込み時に正しく体験一覧が取得できなかったため暫定対処
    #   ver2.0リリースまでにclickings.contextに"再訪したい"を追加し、この暫定対処を吸収したい。
    sorted_experiences = Experience.sort_by_evaluation(filtered_experiences, @sort_type)
    @checked_experiences = sorted_experiences.page params[:page]
    @checked_experiences = @checked_experiences.with_photos unless @context_filter == 'revisit'

    # ranked experiences
    ranked_experiences = Experience.ranked_by(current_user).with_photos
    # TODO: 以下の記述動作できていれば、scope化
    unranked_experiences = Experience.filter_by_click_context('go', current_user).where.not(id: ranked_experiences.pluck(:id)).posted_order.with_photos
    @experience_ranking = Kaminari.paginate_array(ranked_experiences + unranked_experiences).page params[:page]
    @checked_experience_ranking = Kaminari.paginate_array(ranked_experiences + unranked_experiences).page params[:page]

    # sort button path
    @sort_path = mypage_path

    # 獲得バッジ
    # TODO: リファクタリングが必要
    pref_tags = select_tag_names("prefectures", sorted_experiences)
    genre_tags = select_tag_names("genres", sorted_experiences)
    @gold_badges   = [ badge_count(pref_tags, Constants.badge_counts.gold)  , badge_count(genre_tags, Constants.badge_counts.gold)   ]
    @silver_badges = [ badge_count(pref_tags, Constants.badge_counts.silver), badge_count(genre_tags, Constants.badge_counts.silver) ]
    @bronze_badges = [ badge_count(pref_tags, Constants.badge_counts.bronze), badge_count(genre_tags, Constants.badge_counts.bronze) ]

    uploaded_photos = Photo.joins(:user_photos).where(user_photos: {user_id: current_user.id })
    @uploaded_photos_count = uploaded_photos.count
    @uploaded_experience_photos = uploaded_photos.order(created_at: :desc).page(params[:photos_page])
    @following_count = @user.follows.count
    # TODO: フォロワーの取得をscope化
    @follower_count = Follow.where(following_id: @user.id).count
    @unread_followers = Follow.where(following_id: @user.id, read: false)
    @unread_score_logs = @user.score_logs.where(read: false)
  end

  def privacy_policy
    @unauthenticated = params[:unauthenticated]
    current_user.count_action(:refered_menu_privacy_policy) if current_user
  end

  def add_tag_filter
    if params[:tag]
      add_tag = ActsAsTaggableOn::Tag.joins(:translations).find_by(tag_translations: { name: params[:tag].gsub(/\+/, ' ') })
      if add_tag.present?
        @tag_names << add_tag.name unless @tag_names.include?(add_tag.name)
        session[:filter_tag_ids] = ActsAsTaggableOn::Tag.joins(:translations).where(tag_translations: { name: @tag_names }).pluck(:id)
      end
    elsif params[:context_filter]
      @context_filter = params[:context_filter]
      session[:context_filter] = @context_filter
    end
    current_user.count_action(:used_filter_by_tag) if current_user
    # TODO HACK: 未ログインユーザーでタグ検索した場合、ログインモーダル出さないようにする対処。要リファクタ
    flash[:login_modal_disable] = true
    filterd_redirect_path(params[:to] || "/")
  end

  def remove_tag_filter
    if params[:tag]
      # tags.nameカラムの値を参照するためpluck(:name)を使う
      remove_tag = ActsAsTaggableOn::Tag.joins(:translations).where(tag_translations: { name: params[:tag].gsub(/\+/, ' ') })
      if remove_tag.present?
        @tag_names.delete(remove_tag.pluck(:name).first)
        session[:filter_tag_ids] = ActsAsTaggableOn::Tag.joins(:translations).where(tag_translations: { name: @tag_names }).pluck(:id)
      end
    elsif params[:context_filter]
      @context_filter = nil
      session.delete(:context_filter)
    end
    # TODO HACK: 未ログインユーザーでタグ検索した場合、ログインモーダル出さないようにする対処。要リファクタ
    flash[:login_modal_disable] = true
    filterd_redirect_path(params[:to] || "/")
  end

  def set_locale
    cookies[:locale] = filtered_locale params[:new_locale]
    redirect_to :back
  end

  private

  # TODO HACK: users_controllerにも同記述があるので、concernsに移す
  def set_tag_names
    if params[:keyword] && params[:tag].nil?
      tag_ids = ActsAsTaggableOn::Tag.joins(:translations).where(tag_translations: { name: params[:keyword] }).pluck(:id)
      session.delete(:filter_tag_ids)
      session[:filter_tag_ids] = tag_ids
    else
      tag_ids = session[:filter_tag_ids] ? session[:filter_tag_ids] : nil
    end
    @tags = ActsAsTaggableOn::Tag.eager_load(:translations).where(id: tag_ids, tag_translations: {locale: I18n.locale})
    # NOTE: @tags.pluck(:name)だとtag_translationsのnameではなくtagsのname(日本語)が取られるので注意
    @tag_names = @tags.pluck(:name)
  end

  def set_sort_type
    @sort_type = params[:sort]
  end

  def set_context_filter
    context = session[:context_filter] ? session[:context_filter] : nil
    @context_filter = context
  end

  def select_tag_names(context, exps)
    ActsAsTaggableOn::Tag.joins(:taggings, :translations)
                         .order(taggings_count: :desc)
                         .where(taggings: { context: context, taggable_id: exps.pluck(:id).uniq }, tag_translations: {locale: I18n.locale})
                         .pluck("tag_translations.name")
  end

  def filterd_redirect_path(to)
    if (to == root_path) && session[:sort].nil?
      redirect_to(root_path)
    else
      redirect_to(view_context.remove_query(request.referer, "page"))
    end
  end

  def badge_count(tags, count)
    if count == Constants.badge_counts.gold
      tags.select{|n| tags.count(n) >= count}.uniq
    else
      tags.select{|n| tags.count(n) == count}.uniq
    end
  end

  # カレントページ内に表示される広告コンテンツの表示数と表示される広告コンテンツの総数に応じて,
  # 通常コンテンツのページネーション用パラメータを計算する
  # @param [Experience] current_page_ad 現在のページ内に表示される広告コンテンツ
  # @param [Integer] total 表示される広告コンテンツの総数
  # @return [Array] ページネーションパラメータ
  def calc_adjust_pagination_params(current_page_ad, total)
    n = params[:page].to_i
    page = n > 1 ? n : 1

    ad_count    = current_page_ad.count

    # TODO: 要リファクタ。「再訪したい」のcountがHashで返ってしまうので暫定的に対処。
    ad_count = ad_count.keys.count if ad_count.is_a?(Hash)
    total = total.keys.count if total.is_a?(Hash)

    base_cpp    = Constants::counts_per_page
    base_ad_cpp = Constants::counts_per_page_for_ad

    if ad_count == 0
      cpp     = base_cpp
      padding = total
    elsif base_ad_cpp > ad_count
      cpp     = base_cpp - (base_ad_cpp - ad_count)
      padding = (base_ad_cpp - ad_count) * (page - 1)
    else
      cpp     = base_cpp - ad_count
      padding = 0
    end

    return [page, cpp, padding]
  end

  def update_context_filter
    context_filter = params[:context_filter]
    @context_filter =
      if context_filter
        context_filter
      elsif session[:filter_click_context]
        session[:filter_click_context]
      else
        'go'
      end
    session[:filter_click_context] = @context_filter
  end

  def signout_if_curator
    if current_user.try(:user_type)
      sign_out
      redirect_to root_path
    end
  end
end
