# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate!, except: %i[destroy]

  def new
  end

  def create
    user = User.authenticate_by(params.permit(:username, :password))
    if user
      reset_session
      session[:user_id] = cookies.permanent.encrypted[:user_id] = user.id
      redirect_to root_path
    else
      render action: :new
    end
  end

  def destroy
    cookies.delete(:user_id)
    reset_session
    redirect_to login_path
  end
end
