# frozen_string_literal: true

require 'lograge/sql/version'

# Main Lograge module
module Lograge
  # Main gem module
  module Sql
    class << self
      # Format SQL log
      attr_accessor :formatter
      # Extract information from SQL event
      attr_accessor :extract_event
      # Keep just a counter of SQL queries
      attr_accessor :counter_only

      # Initialise configuration with fallback to default values
      def setup(config)
        Lograge::Sql.formatter     = config.formatter     || default_formatter
        Lograge::Sql.extract_event = config.extract_event || default_extract_event
        Lograge::Sql.counter_only  = config.counter_only  || false

        # Disable existing ActiveRecord logging
        unless config.keep_default_active_record_log
          ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
            Lograge.unsubscribe(:active_record, subscriber) if subscriber.is_a?(ActiveRecord::LogSubscriber)
          end
        end

        return unless defined?(Lograge::ActiveRecordLogSubscriber)

        Lograge::ActiveRecordLogSubscriber.attach_to(:active_record)
      end

      # Gets the store, preferring RequestStore if the gem is found.
      # @return [Hash, Thread] the RequestStore or the current Thread.
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
