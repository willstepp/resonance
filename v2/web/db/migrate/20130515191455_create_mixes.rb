class CreateMixes < ActiveRecord::Migration
  def change
    create_table :mixes do |t|
      t.string :uuid
      t.string :name
      t.string :sounds
      t.integer :state, :default => 0

      t.timestamps
    end
  end
end
