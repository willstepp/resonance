class CreateSounds < ActiveRecord::Migration
  def change
    create_table :sounds do |t|
      t.string :name
      t.string :filename
      t.string :filetype
      t.text :description

      t.timestamps
    end
  end
end
