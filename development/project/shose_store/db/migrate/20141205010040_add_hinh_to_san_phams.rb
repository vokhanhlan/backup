class AddHinhToSanPhams < ActiveRecord::Migration
  def change
     add_attachment :san_phams, :hinh
  end
end
