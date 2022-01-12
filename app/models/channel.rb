class Channel < ApplicationRecord
  encrypts :secret

  has_many :messages, -> { order(id: :desc) }, dependent: :destroy
end
