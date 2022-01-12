class AddSecretToChannels < ActiveRecord::Migration[7.0]
  def change
    add_column :channels, :secret, :text
  end
end
