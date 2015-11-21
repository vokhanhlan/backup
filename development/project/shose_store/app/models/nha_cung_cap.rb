class NhaCungCap < ActiveRecord::Base
	has_many :san_phams
	validates :ten , uniqueness: true
end
