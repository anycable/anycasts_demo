# frozen_string_literal: true

class AddChannelsNameUniqueness < ActiveRecord::Migration[7.0]
  def change
    change_column_null :channels, :name, false

    add_index :channels, :name, unique: true
  end
end
