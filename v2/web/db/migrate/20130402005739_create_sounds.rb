class CreateSounds < ActiveRecord::Migration
  def change
    create_table :sounds do |t|
      t.string :name
      t.text :description
      t.string :uuid
      t.string :slug

      t.timestamps
    end
  end
end
