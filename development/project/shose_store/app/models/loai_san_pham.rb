class LoaiSanPham < ActiveRecord::Base
  has_one :san_phams
  validates :ten , uniqueness: true
end
