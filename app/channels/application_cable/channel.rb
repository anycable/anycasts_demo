module ApplicationCable
  class Channel < ActionCable::Channel::Base
    include AnyCable::Rails::Channel::Presence
  end
end
