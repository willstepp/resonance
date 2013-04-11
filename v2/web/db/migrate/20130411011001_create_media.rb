class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.string :filename
      t.string :type
      t.integer :sound_id

      t.timestamps
    end
  end
end
