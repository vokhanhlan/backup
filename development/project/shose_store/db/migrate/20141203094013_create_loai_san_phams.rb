class CreateLoaiSanPhams < ActiveRecord::Migration
  def change
    create_table :loai_san_phams do |t|
      t.string :ten
      t.integer :ma_loai_cha

      t.timestamps
    end
  end
end
