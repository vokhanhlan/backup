# == Schema Information
#
# Table name: experiences
#
#  id          :integer          not null, primary key
#  title       :string(255)      not null
#  description :text(65535)      not null
#  address     :string(255)
#  tel         :string(255)
#  url         :string(255)
#  workday     :string(255)
#  start_date  :datetime
#  end_date    :datetime
#  price       :integer
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_experiences_on_advertiser_id  (advertiser_id)
#

class Experience < ActiveRecord::Base
  has_many :experience_photos, dependent: :destroy
  has_many :photos, through: :experience_photos
  has_many :clickings, dependent: :destroy
  has_many :clicking_users, through: :clickings, source: :user
  has_many :affiliations
  has_many :rankings, dependent: :destroy
  belongs_to :advertiser

  accepts_nested_attributes_for :experience_photos

  # for globalize and globalize-accessors
  translates :title, :description, :address, :workday
  globalize_accessors locales: [:en, :ja, :ko, :th], attributes: [:title, :description, :address, :workday]

  # for acts-as-taggable-on
  acts_as_taggable_on :prefectures, :genres

  # validates
  validates :title,       presence: true

  # Scopes

  # for Globalize translations eager loading
  default_scope { eager_load(:translations) }

  # TODO: This scope is not using now except spec. In the case of this state, this scope will be removed in the future.
  scope :valid_clickings, ->() do
    eager_load(:translations, :clickings)
      .where(clickings: {deleted: false}, experience_translations: {locale: I18n.locale})
      .group("experiences.id")
  end

  # 広告コンテンツ向け
  scope :regular_contents, ->() { where(advertiser_id: nil) }
  scope :ad_contents,      ->() { where.not(advertiser_id: nil) }
  scope :publishable,      ->() { where(arel_table[:end_date].gteq(Date.today)) }

  # 行きたい、行った、また行きたい
  scope :clicked_as_wish_to_go_by, ->(user_id) do
    joins(:clickings).where(clickings: {user_id: user_id, deleted: false, context: 0})
  end
  scope :clicked_as_been_there_by, ->(user_id) do
    joins(:clickings).where(clickings: {user_id: user_id, deleted: false, context: 1})
  end
  scope :clicked_as_going_again_by, ->(user_id) do
    joins(:clickings)
      .where(clickings: {user_id: user_id, deleted: false}, experience_translations: {locale: I18n.locale})
      .group("clickings.experience_id")
      .having("COUNT(clickings.experience_id) = 2")
  end

  # Eager loading
  scope :with_photos, ->() { eager_load(:photos) }

  # 並び替え
  scope :posted_order,     -> { order(created_at: :desc) }
  scope :evaluation_order, -> { order(score: :desc).posted_order }

  # Ranked experiences
  scope :ranked_by, ->(user_id) do
    joins(:rankings)
      .where(rankings: { user_id: user_id })
      .order('rankings.rank ASC')
  end

  # Curation

  # Get list experices of the curator create
  # TODO:
  # - Select items form experiences where author equal current_user.id
  # - Paging 10 item per page
  # @params:
  # - curator_id: Id of curator user
  # - page: number of current page
  # @result: list experience
  scope :get_list_experience_by_user, -> (curator_id, page) do

  end

  # Class methods

  class << self
    # マイページ、ユーザーページ用
    # 特定ユーザーがクリックしたコンテキスト毎の体験を取得
    def filter_by_click_context(click_context, user)
      if click_context == 'go'
        # "行った" がON状態
        clicked_as_wish_to_go_by(user.id)
      elsif click_context == 'went'
        # "行きたい" がON状態
        clicked_as_been_there_by(user.id)
      elsif click_context == 'revisit'
        # "また行きたい" がON状態
        clicked_as_going_again_by(user.id)
      else
        raise "Unexpected button click condition has occurred at Experience#filter_by_click_context."
      end
    end

    # TODO HACK: empty?時はself.scopedを返せばscope化できるかも。
    def filter_by_tag(experiences, tag_names)
      (tag_names.empty?)? experiences : experiences.tagged_with(tag_names)
    end

    def sort_by_evaluation(experiences, sort_type)
      (sort_type == 'by_evaluation')? experiences.evaluation_order : experiences.posted_order
    end

    # タグに関連する体験
    # 体験詳細のタグを持つ体験を抽出
    # 抽出した体験に対して、体験詳細のタグがその体験に何個含まれるかの含有率をみて、
    # 含有率の多い順に表示
    def relation_tag_experiences(exp)
      tags = []
      tag_id = []
      experiences = nil
      # 日本語タグ名で検索しないとtagged_withが使えない
      Globalize.with_locale(:ja) do
        tags << exp.prefecture_list
        tags << exp.genre_list
        tags.flatten!
        experiences = Experience.tagged_with(tags, any: true).to_a
      end
      tag_id = exp.taggings.pluck(:tag_id)
      exps = experiences.inject(Hash.new(0)) do |hash,obj|
        tag_id.each do |id|
          hash[obj.id] += obj.taggings.pluck(:tag_id).count(id)
        end
        hash
      end
      exp_ids = exps.sort_by{|k,v| -v }.to_h.keys
      exp_ids.delete(exp.id)
      Experience.where(id: exp_ids).with_photos.limit(10).to_a.index_by(&:id).slice(*exp_ids).values
    end
  end

  # Instance methods

  def tags_least_used
    ActsAsTaggableOn::Tag.eager_load(:taggings).where(taggings: {taggable: id}).least_used
  end

  # TODO HACK: Clickingモデルに移動
  # context毎のクリック数を取得
  def click_count(context)
    (context.to_sym == :revisit)? revisit_count : clickings.__send__(context.to_sym).not_deleted.count
  end

  # TODO HACK: Clickingモデルに移動
  # 各コンテンツのボタンクリック取得
  def clickings_find_by_user(context, id)
    return Clicking.none unless context.to_sym == :go || context.to_sym == :went
    clickings.__send__(context.to_sym).not_deleted.where(user_id: id)
  end

  # TODO: app/admin/experience.rb, db/seeds.rbから該当記述を削除し、本メソッドを削除する
  # コンテンツ画像パスの取得
  def photo_path
    photos.first.img_file_name
  end

  def to_param
    "#{id} #{title}".parameterize
  end

  private

  # TODO HACK: Clickingモデルに移動
  # 同一ユーザでgo,wentにクリックしている件数を算出
  def revisit_count
    (user_ids_of(:go) & user_ids_of(:went)).size
  end

  # TODO HACK: Clickingモデルに移動
  # clickingsからuser_idのarrayリストを取得
  def user_ids_of(context)
    clickings_search(context, :user_id).uniq
  end

  # TODO HACK: Clickingモデルに移動
  def clickings_search(context, column)
    clickings.__send__(context.to_sym).not_deleted.pluck(column.to_sym)
  end

  # Add new an experience
  # TODO:
  # - Insert into table experience and experience_translations
  # - Inster into table tags, tag_translations and taggings
  # - Inster into table photos  and experience_photos
  # - Rollback data insert if fail
  def create_experience(exp_params)

  end

  # Update an experience
  # TODO:
  # - Update into table experience and experience_translations
  # - Update into table tags, tag_translations and taggings
  # - Update into table photos  and experience_photos
  # - Rollback data insert if fail
  def update_experience(exp_params)

  end
end
