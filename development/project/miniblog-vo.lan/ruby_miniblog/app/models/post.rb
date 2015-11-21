class Post < ActiveRecord::Base 
  belongs_to :user
  has_many :comment

  validates :description, length: { maximum: 255 }
  validates :content, length: { minimum: 255 }
  validates_uniqueness_of :title

  has_attached_file :image, :styles => { :medium => "320x300>", :thumb => "120x100" }, :default_url => "/system/posts/images/default/:style/missing.jpg"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

# sort order by created_at
  default_scope  { order(:created_at => :desc) }

# View all post of user  
  scope :post_of_user, ->(user_post) {where("user_id = #{user_post}")}
  
# update count view for post
def update_count_view(id,count_view)
 post = Post.find id
 post = post.update(:count_view => count_view + 1)
  
end

end
 