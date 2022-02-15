module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user
  end
end
