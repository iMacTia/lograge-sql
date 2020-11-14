# frozen_string_literal: true

require 'rails/railtie'
require 'active_support/ordered_options'

module Lograge
  module Sql
    # Railtie to automatically setup in Rails
    class Railtie < Rails::Railtie
      # To ensure that configuration is not nil when initialise Lograge::Sql.setup
      config.lograge_sql = ActiveSupport::OrderedOptions.new

      config.to_prepare do
        Lograge::Sql.setup(Rails.application.config.lograge_sql)
      end
    end
  end
end
