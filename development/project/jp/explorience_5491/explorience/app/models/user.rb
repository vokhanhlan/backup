# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  name                     :string(40)       not null
#  email                    :string(255)      default(""), not null
#  score                    :integer          default(0)
#  last_sign_in_checking_at :datetime
#  encrypted_password       :string(255)      default(""), not null
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer          default(0), not null
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  confirmation_token       :string(255)
#  confirmed_at             :datetime
#  confirmation_sent_at     :datetime
#  unconfirmed_email        :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  user_type                :string(255)
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ActiveRecord::Base
  has_many :providers, dependent: :destroy
  # NOTE: user_photosはbefore_destroyでphotoからdestroyする
  has_many :user_photos
  has_many :photos, through: :user_photos
  has_many :clickings, dependent: :destroy
  has_many :clicking_experiences, through: :clickings, source: :experience
  has_many :fixed_photos, dependent: :destroy
  has_many :follows, dependent: :destroy
  has_many :rankings, dependent: :destroy
  has_many :score_logs, dependent: :destroy
  has_one  :action_log, dependent: :destroy

  before_destroy :destroy_associated_record

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: [:twitter, :facebook, :google]

  # for acts-as-taggable-on
  acts_as_tagger

  # validates
  validates :name, presence: true, length: { maximum: 20 }

  # Scopes
  scope :clicked, -> { joins(:clickings).where(clickings: { deleted: false }) }
  scope :without, ->(user_id) { where.not(id: user_id) }
  scope :with_providers, -> { eager_load(:providers) }

  # click数超過チェック
  def clickable?(target_id=nil, context='go')
    if context == 'go' && !experience_ids_of(:went).include?(target_id.to_i)
      clicked_exp_ids = experience_ids_of(:go) - experience_ids_of(:went)
      limit = Constants.limit_of_click
      ((clicked_exp_ids.size < limit) || (clicked_exp_ids.include?(target_id.to_i)))? true : false
    else
      true
    end
  end

  # 行動履歴カウント
  def count_action(action_type)
    ActiveRecord::Base.transaction do
      create_action_log unless action_log
      action_log.increment!(action_type.to_sym)
    end
  end

  # TODO: HACK: リファクタリング(Experienceモデルにも同記述あり)
  def click_count(context)
    (context.to_sym == :revisit)? revisit_count : clickings.__send__(context.to_sym).not_deleted.count
  end

  # 有効なemailアドレスを取得（Facebookユーザーのみ）
  def valid_email
    self.email unless self.providers.first.twitter?
  end

  class << self
    # TODO: HACK: 共通化
    def find_for_twitter_oauth(auth, signed_in_resource=nil)
      user = User.find_by(id: Provider.twitter.where(sns_id: auth.uid).pluck(:user_id).first)
      if user
        user.providers.twitter.first.update_attributes(nickname: auth.info.nickname, language: auth.extra.raw_info.lang, photo_url: twitter_image_url(auth.info.image))
      else
        user = User.new(
          name:     auth.info.nickname,
          email:    User.create_unique_email,
          password: Devise.friendly_token[0, 20],
          )
        # TODO:エラー処理フロー検討
        begin
          user.save!
          user.providers.create(
            sns_type: :twitter,
            sns_id: auth.uid,
            nickname: auth.info.nickname,
            language: auth.extra.raw_info.lang,
            photo_url: twitter_image_url(auth.info.image)
            )
          user.create_action_log
        rescue
          raise
        end
      end
      user
    end

    def find_for_facebook_oauth(auth, signed_in_resource=nil)
      user = User.find_by(id: Provider.facebook.where(sns_id: auth.uid).pluck(:user_id).first)
      if user
        user.providers.facebook.first.update_attributes(nickname: auth.info.name, language: auth.extra.raw_info.locale, photo_url: facebook_image_url(auth.info.image, size: 120))
      else
        user = User.new(
          name:     auth.info.name,
          email:    auth.info.email,
          password: Devise.friendly_token[0, 20],
          )
        # TODO:エラー処理フロー検討
        begin
          user.save!
          user.providers.create(
            sns_type: :facebook,
            sns_id: auth.uid,
            nickname: auth.info.name,
            language: auth.extra.raw_info.locale,
            photo_url: facebook_image_url(auth.info.image, size: 120)
            )
          user.create_action_log
        rescue
          raise
        end
      end
      user
    end

    def find_for_google_oauth(auth, signed_in_resource=nil)
      user = User.find_by(id: Provider.google.where(sns_id: auth.uid).pluck(:user_id).first)
      if user
        user.providers.google.first.update_attributes(nickname: auth.info.name, language: auth.extra.raw_info.locale, photo_url: google_image_url(auth.info.image))
      else
        user = User.new(
          name:     auth.info.name,
          email:    auth.info.email,
          password: Devise.friendly_token[0, 20],
          )
        # TODO:エラー処理フロー検討
        begin
          user.save!
          user.providers.create(
            sns_type: :google,
            sns_id: auth.uid,
            nickname: auth.info.name,
            language: auth.extra.raw_info.locale,
            photo_url: google_image_url(auth.info.image)
            )
          user.create_action_log
        rescue
          raise
        end
      end
      user
    end

    # 通常サインアップ時のuid用、Twitter OAuth認証時のemail用にuuidな文字列を生成
    def create_unique_string
      SecureRandom.uuid
    end

    # twitterではemailを取得できないので、適当に一意のemailを生成
    def create_unique_email
      User.create_unique_string + "@example.com"
    end

    # TODO: 引数指定でサイズ指定できるようにする
    def twitter_image_url(url)
      url.gsub(/_normal/, '')
    end

    # TODO: user_photo imgクラスのサイズを自前で引数指定しないといけないのでメンテ必要
    def facebook_image_url(url, size: nil)
      parsed = URI.parse(url)
      parsed.query = "width=#{size}&height=#{size}"
      parsed.to_s
    end

    def google_image_url(url)
      url.gsub(/\?sz.+/, '')
    end
  end

  private

  # user削除前にdependent destroyでは削除できない関連レコードを削除
  def destroy_associated_record
    Photo.where(id: self.user_photos.pluck(:photo_id)).destroy_all
    Follow.where(following_id: self.id).destroy_all
  end

  # 同一ユーザでgo,wentにクリックしている件数を算出
  # TODO: HACK: リファクタリング(Experienceモデルにも同記述あり)
  def revisit_count
    (experience_ids_of(:go) & experience_ids_of(:went)).size
  end

  # clickingsからexperience_idのarrayリストを取得
  # TODO: HACK: リファクタリング(Experienceモデルにも同記述あり)
  def experience_ids_of(context)
    clickings_search(context, :experience_id).uniq
  end

  # TODO: HACK: リファクタリング(Experienceモデルにも同記述あり)
  def clickings_search(context, column)
    clickings.__send__(context.to_sym).not_deleted.pluck(column.to_sym)
  end
end
