# frozen_string_literal: true

class ProfilesController < ApplicationController
  def show
    user = User.find(params[:id])

    render partial: "profiles/profile", locals: {user:}
  end
end
