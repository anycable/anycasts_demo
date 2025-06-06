module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user

    def connect
      token = request.params[:jid]

      identifiers = AnyCable::JWT.decode(token)
      identifiers.each do |k, v|
        public_send("#{k}=", v)
      end
    rescue AnyCable::JWT::DecodeError
      reject_unauthorized_connection
    end

    def handle_open
      super
    rescue AnyCable::JWT::ExpiredSignature
      logger.error "An expired JWT token was rejected"
      close(reason: "token_expired", reconnect: false) if websocket.alive?
    end
  end
end
