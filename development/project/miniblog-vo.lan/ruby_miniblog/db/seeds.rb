# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Category.create(name: 'Emanuel', parent_id: 0, status: 1)
Category.create(name: 'Chicago', parent_id: 0, status: 1)
Category.create(name: 'Copenhagen', parent_id: 0, status: 1)
