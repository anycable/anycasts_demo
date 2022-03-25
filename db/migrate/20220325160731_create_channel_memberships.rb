# frozen_string_literal: true

class CreateChannelMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :channel_memberships do |t|
      t.belongs_to :channel, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :channel_memberships, [:channel_id, :user_id], unique: true
  end
end
