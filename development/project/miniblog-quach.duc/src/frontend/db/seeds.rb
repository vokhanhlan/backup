# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   Mayor.create(name: 'Emanuel', city: cities.first)

# CREATE DATABASE FOR POST TABLE
# DESC===========================
# t.string         :title
# t.string         :description
# t.text            :content
# t.string         :thumbnail
# t.integer       :user_id
# t.boolean      :status
# # DELETE=========================
Post.delete_all()
# like
# Rails console
# ActiveRecord::Base.connection.execute("DELETE from posts")
# CREAT==========================
# Creat 20 post
(1..20).each do |e|
  Post.create(title: 'Title'+e.to_s, description: 'Lorem ipsum Sed eiusmod in esse magna veniam quis tempor mollit in ut velit adipisicing qui aliqua qui eiusmod mollit exercitation fugiat.'+e.to_s, content: 'Lorem ipsum Nisi dolor consectetur aliquip laborum tempor proident in ullamco in in anim sit dolore dolor cillum aliqua qui consectetur enim quis non in id eu laborum officia ut consectetur cillum sint.'+e.to_s, thumbnail: 'thumbnail'+e.to_s, user_id: e.to_s, status: true)
end
# # ==============================

# CREATE DATABASE FOR USER TABLE
# DESC===========================
# t.string              :username
# t.string              :first_name
# t.string              :last_name
# t.string              :email
# t.string              :address
# t.string              :encrypt_pass
# t.string              :avatar
# t.boolean           :gender
# t.date                :birthday
# # DELETE=========================
User.delete_all()
# # like
# # Rails console
# # ActiveRecord::Base.connection.execute("DELETE from USERS")
# # CREAT==========================
# (1..20).each do |e|
#   User.create({username: 'username'+e.to_s, first_name: 'first_name'+e.to_s, last_name: 'last_name'+e.to_s, email: 'email'+e.to_s, address: 'address'+e.to_s, encrypt_pass: 'encrypt_pass'+e.to_s, avatar: 'avatar'+e.to_s, gender: true , birthday: '21-05-1992' })
# end
# # ==============================

