class Product < ActiveRecord::Base
  has_many :comments
 
  def as_json(options={})
  	{
  		ten:  name,
  		mota: description_at
  	}
    super.merge(lan: description_at.to_s)
  end

	# def as_json
	# 	{
	# 		:id => id,
	# 		name: name
	# 	}
		
	# end

	def total_price
		123
	end


	def auth_name
		sql = "select pr.name
					from products p, users u, profile pr
					where ... 
		"
		Product.find_by_sql(sql)
		
				
	end

end
