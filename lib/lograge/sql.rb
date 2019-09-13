# frozen_string_literal: true

require 'lograge/sql/version'

module Lograge
  # Main gem module
  module Sql
    class << self
      # Format SQL log
      attr_accessor :formatter
      # Extract information from SQL event
      attr_accessor :extract_event

      # Initialise configuration with fallback to default values
      def setup(config)
        Lograge::Sql.formatter     = config.formatter     || default_formatter
        Lograge::Sql.extract_event = config.extract_event || default_extract_event
      end

      def store
        defined?(RequestStore) ? RequestStore.store : Thread.current
      end

      private

      # By default, the output is a concatenated string of all extracted events
      def default_formatter
        proc do |sql_queries|
          %('#{sql_queries.join("\n")}')
        end
      end

      # By default, only extract values required for the default_formatter and
      # already convert to a string
      def default_extract_event
        proc do |event|
          "#{event.payload[:name]} (#{event.duration.to_f.round(2)}) #{event.payload[:sql]}"
        end
      end
    end
  end
end

# Rails specific configuration
require 'lograge/sql/railtie' if defined?(Rails)
