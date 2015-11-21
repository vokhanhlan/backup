class Comment < ActiveRecord::Base
	belongs_to :product
	# rails_admin do
 #    configure :product do
 #      label 'Owner of this product: '
 #    end
 #  end
end
