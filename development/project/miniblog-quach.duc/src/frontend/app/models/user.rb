class User < ActiveRecord::Base
  has_many :posts
  has_many :comments

  attr_accessor :password
  before_save  :ecrypt_password

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :username
  validates_uniqueness_of :username

  def self.authenticate(username, password)
    # Find user by username
    user = find_by_username(username)
    # Check user exist and check input password with encrypt password
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      #Return this user
      user
    else
      nil
    end
  end

  def ecrypt_password
    # If have password, BCrypt generate key and encrypt password with this key
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end



  # has_secure_password

  # accepts_nested_attributes_for :comments
  # attr_accessor :password_digest

  # filter_parameter_logging :password, :password_confirmation

  # ========= Validation =========== #
  # validates :password, confirmation: true
  # validates :email, presence: true, uniqueness: true, length: 8..50, format: { with: /\A[a-z0-9\.]+@([a-z]{1,10}\.){1,2}[a-z]{2,4}\z/,message: "Invalid Email"}
  # validates :username, presence: true, uniqueness: true, length: 6..40
  # validates :first_name, presence: true, length: 2..50
  # validates :last_name, presence: true, length: 2..50
  # validates :avatar, format: {with: /\A*\.(JPEG|JPG|PNG|GIF|BMP|ICO)\z/i, message: "Your images incorrect formated, it must be formatted as: jpeg, png, gif, bmp, icon "}
  # validates :gender, numericality: true
  # # validates :display_name, uniqueness: true, length: 3..50
  # validates :birthday, format: {with: /\A[\d\/-]{10}\z/}
  # validates :status, numericality: true, length: {is: 1}, on: :update
  # validates :permission, length: {is: 5}, :on => :update
  # validates :address, length: 4..50

  # # preprocessor
  # before_save { email.downcase! }
  # before_save :create_token

  # # search_syntax do
  # #   search_by :text do |scope, phrases|
  # #     columns = [:first_name, :last_name, :username]
  # #     scope.where_like(columns => phrases)
  # #   end
  # # end

  # # Issue https://my.redmine.jp/mulodo/issues/21936
  # # Create User Account
  # def self.create_user(user_params)
  #   # Params
  #   password_salt = BCrypt::Engine.generate_salt
  #   password = BCrypt::Engine.hash_secret(user_params[:password], password_salt)
  #   params = {
  #       password: password,
  #       password_salt: password_salt,
  #       username: user_params[:username],
  #       email: user_params[:email],
  #       first_name: user_params[:first_name],
  #       last_name: user_params[:last_name],
  #       avatar: user_params[:avatar],
  #       gender: user_params[:gender],
  #       display_name: user_params[:display_name],
  #       birthday: user_params[:birthday],
  #       address: user_params[:address]
  #   }
  #   # Save new user
  #   begin
  #     user = User.new(params)
  #     user.save!
  #     return {meta:{code: STATUS_OK, description:"Account is created successfully",
  #             messages:"Successful"},data: params}
  #   rescue => e
  #     if user.invalid?
  #       return {meta:{code: ERROR_VALIDATE[0], description:ERROR_VALIDATE[1],
  #               messages:user.errors},data:nil}
  #     else
  #       return {meta:{code: ERROR_INSERT_USER[0], description:ERROR_INSERT_USER[1],
  #               messages: e.to_s},data:nil}
  #     end
  #   end
  # end

  # # https://my.redmine.jp/mulodo/issues/21938
  # # User login
  # def self.user_login(user_params)
  #   # Check object nil
  #   if user_params[:username].blank? || user_params[:password].blank?
  #     return {meta:{code: ERROR_USERNAME_OR_PASSWORD_FAILED[0], description:ERROR_USERNAME_OR_PASSWORD_FAILED[1],
  #             messages: 'Invalid params'},data:nil}
  #   else
  #     # Check username & password
  #     user = User.authenticate(user_params[:username], user_params[:password])
  #     if user.blank?
  #       return {meta:{code: ERROR_LOGIN_FAILED[0], description:ERROR_LOGIN_FAILED[1],
  #               messages:"Login failed."},data: user_params}
  #     else
  #       # return value
  #       return {meta:{code: STATUS_OK, description:"Account login successfully",
  #               messages:"Successful"},data: User.select(:token, :id, :permission).find(user.id)}
  #     end
  #   end
  # end

  # # Task https://my.redmine.jp/mulodo/issues/21940
  # # User logout
  # def self.get_token(user_id)
  #   return User.select(:token).find(user_id).token
  # end

  # def self.changed_password
  #   if params[:password].present? && params[:password_confirmation].present?
  #     update_attributes( params )
  #   else
  #     errors.add(:password, "and confirmation must both be provided to reset your password")
  #     false
  #   end
  # end

  # # Task https://my.redmine.jp/mulodo/issues/21944
  # #
  # def self.get_user_info(user_id)
  #   begin
  #     User.select(
  #         :username, :first_name, :last_name, :display_name, :birthday, :permission,
  #         :avatar, :gender, :email, :address, :status, :created_at, :updated_at
  #     ).find(user_id)
  #   rescue => e
  #     nil
  #   end
  # end

  # # Task https://my.redmine.jp/mulodo/issues/21943
  # # PUT/PATCH apis/:id/update_user_info
  # def self.update_user(user_id,user_params)
  #   data = {
  #       first_name: user_params[:first_name],
  #       last_name: user_params[:last_name],
  #       display_name: user_params[:display_name],
  #       birthday: user_params[:birthday],
  #       avatar: user_params[:avatar],
  #       gender: user_params[:gender],
  #       email: user_params[:email],
  #       address: user_params[:address]
  #   }
  #   begin
  #     User.where(:id => user_id).update_attribute(data)
  #     return {meta:{code: STATUS_OK, description:"Update user info successfully",
  #                     messages:"Successful"},data: user_params}
  #   rescue => e
  #     if user.invalid?
  #       return {meta:{code: ERROR_VALIDATE[0], description:ERROR_VALIDATE[1],
  #                     messages:user.errors},data:nil}
  #     else
  #       return {meta:{code: ERROR_UPDATE_USER[0], description:ERROR_UPDATE_USER[1],
  #                     messages:"Update user failed."},data: nil}
  #     end
  #   end
  # end

  # # Task https://my.redmine.jp/mulodo/issues/21947
  # # PUT/PATCH apis/:id/change_password
  # def self.change_password(user_id, username,user_params)
  #   begin
  #     # compare password
  #     user = User.authenticate(username, user_params[:password])
  #     if user
  #       User.where(:id => user_id).update_attribute(password: user_params[:password])
  #       return {meta:{code: STATUS_OK, description:"Change password successfully",
  #                     messages:"Successful"},data: user_params}
  #     else
  #       return {meta:{code: ERROR_PASSWORD_COMPARE[0], description:ERROR_PASSWORD_COMPARE[1],
  #                     messages:"Password compare with database not match."},data: user_params}
  #     end
  #   rescue => e
  #     return {meta:{code: ERROR_CHANGED_PASSWORD[0], description:ERROR_CHANGED_PASSWORD[1],
  #                     messages:"Change password failed."},data: nil}
  #   end
  # end

  # # Task https://my.redmine.jp/mulodo/issues/21947
  # # GET apis/search_user_by_name/:keyword(/:limit/:offset
  # def self.search_user_by_name(keyword, limit, offset)
  #   begin
  #     users = User.search(keyword)
  #     data = []
  #     for user in users
  #       temp_data = {id: user.id, username: user.username, firstname: user.firstname,
  #                    lastname: user.lastname, avatar: user.avatar}
  #       data << temp_data
  #     end
  #     return {meta:{code: STATUS_OK, description:"Change password successfully",
  #                   messages:"Successful"},data: user_params}
  #   rescue => e
  #     return {meta:{code: ERROR_SEARCH_FAILED[0], description:ERROR_SEARCH_FAILED[1],
  #                   messages:"Search failed."},data: nil}
  #   end
  # end

  # private
  #   def create_token
  #     self.token = SecureRandom.urlsafe_base64 if token.nil?
  #   end
  #   # Check login
  #   # Return: user object or nil
  #   def self.authenticate(username, password)
  #     user = User.where(username: username).first
  #     # Encrypt password to compare
  #     if user && user.password == BCrypt::Engine.hash_secret(password, user.password_salt)
  #       user
  #     else
  #       nil
  #     end
  #   end
end
