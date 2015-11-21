module UsersHelper

	def genders
		@genders = [['Male', '0'], ['Female', '1'], ['Other','2']]
		
	end

	def active_status
		@status = [['Active', '1'], ['No', '0']]

	end
end
