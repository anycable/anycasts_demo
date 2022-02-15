class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # A shim for Rails 7 method: https://github.com/rails/rails/pull/43765
  def self.authenticate_by(params)
    password = params.delete("password")
    find_by(params)&.authenticate(password)
  end
end
