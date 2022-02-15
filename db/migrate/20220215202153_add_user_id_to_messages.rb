# frozen_string_literal: true

class AddUserIdToMessages < ActiveRecord::Migration[7.0]
  def change
    remove_column :messages, :author, :string
    add_belongs_to :messages, :user, null: false, foreign_key: true
  end
end
