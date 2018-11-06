require 'rails/railtie'
require 'active_support/ordered_options'

module Lograge
  module Sql
    class Railtie < Rails::Railtie
      # To ensure that configuration is not nil when initialise Lograge::Sql.setup
      config.lograge_sql = ActiveSupport::OrderedOptions.new

      config.after_initialize do |app|
        Lograge::Sql.setup(app.config.lograge_sql)
      end
    end
  end
end