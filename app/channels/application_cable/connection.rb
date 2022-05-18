module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user

    def connect
      token = request.params[:jid]

      identifiers = AnyCable::Rails::JWT.decode(token)
      identifiers.each do |k, v|
        public_send("#{k}=", v)
      end
    rescue JWT::DecodeError
      reject_unauthorized_connection
    end

    def presence_user_id
      user.id
    end
  end
end
