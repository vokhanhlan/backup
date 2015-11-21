class Product < ActiveRecord::Base
	translates :name, :description
	has_many :product_translations
	accepts_nested_attributes_for :product_translations ,:allow_destroy => true
end
