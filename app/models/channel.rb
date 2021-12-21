class Channel < ApplicationRecord
  has_many :messages, -> { order(id: :desc) }, dependent: :destroy
end
