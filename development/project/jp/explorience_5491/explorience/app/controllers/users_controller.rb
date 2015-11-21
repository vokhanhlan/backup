class UsersController < ApplicationController
  before_action :set_tag_names
  before_action :set_sort_type
  before_action :update_context_filter

  def show
    @unauthenticated = params[:unauthenticated]
    @user = User.find(params[:id])
    @user_name             = @user.providers.first.nickname
    @user_image            = @user.providers.first.photo_url
    @clicked_count_revisit = @user.click_count(:revisit)
    @clicked_count_go      = @user.click_count(:go)
    @clicked_count_went    = @user.click_count(:went)

    clicked_experiences_filter_by_context = Experience.filter_by_click_context(@context_filter, @user)
    # TODO: ver2.0リリースに向け、一時的に機能マスク
    #filtered_experiences = Experience.filter_by_tag(clicked_experiences_filter_by_context, @tag_names)
    filtered_experiences = clicked_experiences_filter_by_context
    # TODO HACK: 再訪体験絞り込み時に正しく体験一覧が取得できなかったため暫定対処
    #   ver2.0リリースまでにclickings.contextに"再訪したい"を追加し、この暫定対処を吸収したい。
    sorted_experiences = Experience.sort_by_evaluation(filtered_experiences, @sort_type)
    @checked_experiences = sorted_experiences.with_photos unless @context_filter == 'revisit'
    @checked_experiences = sorted_experiences.page params[:page]

    # ranked experiences
    ranked_experiences = Experience.ranked_by(@user).with_photos
    # TODO: 以下の記述動作できていれば、scope化
    unranked_experiences = Experience.filter_by_click_context('go', @user).where.not(id: ranked_experiences.pluck(:id)).posted_order.with_photos
    @experience_ranking = Kaminari.paginate_array(ranked_experiences + unranked_experiences).page params[:page]

    # 獲得バッジ
    # TODO: リファクタリングが必要
    pref_tags = select_tag_names("prefectures", sorted_experiences)
    genre_tags = select_tag_names("genres", sorted_experiences)
    @gold_badges   = [ badge_count(pref_tags, Constants.badge_counts.gold)  , badge_count(genre_tags, Constants.badge_counts.gold)   ]
    @silver_badges = [ badge_count(pref_tags, Constants.badge_counts.silver), badge_count(genre_tags, Constants.badge_counts.silver) ]
    @bronze_badges = [ badge_count(pref_tags, Constants.badge_counts.bronze), badge_count(genre_tags, Constants.badge_counts.bronze) ]

    @sort_path = user_path
    uploaded_photos = Photo.joins(:user_photos).where(published: true, user_photos: {user_id: @user.id})
    @uploaded_photos_count = uploaded_photos.count
    @uploaded_experience_photos = uploaded_photos.order(created_at: :desc).page(params[:photos_page])
    @following_count = @user.follows.count
    # TODO: フォロワーの取得をscope化
    @follower_count = Follow.where(following_id: @user.id).count
    current_user.count_action(:refered_user_page) if current_user
  end

  private

  # TODO: top.controllerに同じ記述があるので共通化したい
  def set_tag_names
    tag_ids = session[:filter_tag_ids] ? session[:filter_tag_ids] : []
    @tags = ActsAsTaggableOn::Tag.where(id: tag_ids)
    # NOTE: @tags.pluck(:name)だとtag_translationsのnameではなくtagsのname(日本語)が取られるので注意
    @tag_names = @tags.pluck(:name)
  end

  def set_sort_type
    @sort_type = params[:sort]
  end

  def select_tag_names(context, exps)
    ActsAsTaggableOn::Tag.joins(:taggings, :translations)
                         .where(taggings: { context: context, taggable_id: exps.pluck(:id).uniq }, tag_translations: {locale: I18n.locale})
                         .pluck("tag_translations.name")
  end

  def badge_count(tags, count)
    if count == Constants.badge_counts.gold
      tags.select{|n| tags.count(n) >= count}.uniq
    else
      tags.select{|n| tags.count(n) == count}.uniq
    end
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
end
