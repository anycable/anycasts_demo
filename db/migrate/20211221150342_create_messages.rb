class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.string :content, null: false
      t.string :author, null: false

      t.belongs_to :channel, index: true, null: false

      t.timestamps
    end
  end
end
