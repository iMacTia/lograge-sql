# frozen_string_literal: true

module Lograge
  # Log subscriber to replace ActiveRecord's default one
  class ActiveRecordLogSubscriber < ActiveSupport::LogSubscriber
    # Every time there's an SQL query, stores it into the Thread.
    # They'll later be accessed from the RequestLogSubscriber.
    def sql(event)
      increase_runtime_duration(event)
      return unless valid?(event)

      filter_query(event)
      store(event)
    end

    private

    # Add the event duration to the overall ActiveRecord::RuntimeRegistry.sql_runtime;
    # note we don't do this when `keep_default_active_record_log` is enabled,
    # as ActiveRecord is already adding the duration.
    def increase_runtime_duration(event)
      return if Rails.application.config.lograge_sql.keep_default_active_record_log

      ActiveRecord::RuntimeRegistry.sql_runtime ||= 0.0
      ActiveRecord::RuntimeRegistry.sql_runtime += event.duration
    end

    def filter_query(event)
      return unless Lograge::Sql.query_filter

      # Filtering out sensitive info in SQL query if custom query_filter is provided
      event.payload[:sql] = Lograge::Sql.query_filter.call(event.payload[:sql])
    end

    def valid?(event)
      return false if event.payload[:name]&.match?(Lograge::Sql.query_name_denylist)

      # Only store SQL events if `event.duration` is greater than the configured +min_duration+
      # No need to check if +min_duration+ is present before as it defaults to 0
      return false if event.duration.to_f.round(2) < Lograge::Sql.min_duration_ms.to_f

      true
    end

    def store(event)
      Lograge::Sql.store[:lograge_sql_queries] ||= []
      Lograge::Sql.store[:lograge_sql_queries] << Lograge::Sql.extract_event.call(event)
    end
  end
end
