# == Schema Information
#
# Table name: guides
#
#  id         :integer          not null, primary key
#  section    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class Guide < ActiveRecord::Base

  # for globalize and globalize-accessors
  translates :title, :body
  globalize_accessors locales: [:en, :ja], attributes: [:title, :body]
end
