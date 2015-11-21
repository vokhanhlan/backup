# == Schema Information
#
# Table name: initial_data_files
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class InitialDataFile < ActiveRecord::Base
end
