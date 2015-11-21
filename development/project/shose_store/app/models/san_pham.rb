class SanPham < ActiveRecord::Base
	acts_as_commentable
	has_one :loai_san_pham
	has_many :nha_cung_caps
	validates :ten,:mo_ta, :ma_loai_san_pham, :presence => true
	has_attached_file :hinh, :styles => { :medium => "197x200>", :thumb => "100x100>" }, :default_url => "/system/san_phams/hinhs/default/:style/missing.jpg"
	validates_attachment_content_type :hinh, :content_type => /\Aimage\/.*\Z/
	scope :avaiable ,->{where("LENGTH(title) >3")}
end
