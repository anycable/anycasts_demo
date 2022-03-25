# frozen_string_literal: true

class AddKindToChannels < ActiveRecord::Migration[7.0]
  def change
    add_column :channels, :kind, :string, null: false, default: "general"
    add_index :channels, :kind
  end
end
