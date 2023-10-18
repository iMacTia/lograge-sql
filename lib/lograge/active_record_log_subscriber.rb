# frozen_string_literal: true

module Lograge
  # Log subscriber to replace ActiveRecord's default one
  class ActiveRecordLogSubscriber < ActiveSupport::LogSubscriber
    # Every time there's an SQL query, stores it into the Thread.
    # They'll later be access from the RequestLogSubscriber.
    def sql(event)
      increase_runtime_duration(event)
      return if event.payload[:name] == 'SCHEMA'

      # Only store SQL events if `event.duration` is greater than the configured +min_duration+
      # No need to check if +min_duration+ is present before as it defaults to 0
      return if event.duration.to_f.round(2) < Lograge::Sql.min_duration_ms.to_f

      # Filtering out sensitive info in SQL query if custom query_filter is provided
      event.payload[:sql] = Lograge::Sql.query_filter.call(event.payload[:sql]) if Lograge::Sql.query_filter

      Lograge::Sql.store[:lograge_sql_queries] ||= []
      Lograge::Sql.store[:lograge_sql_queries] << Lograge::Sql.extract_event.call(event)
    end

    private

    # Add the event duration to the overall ActiveRecord::LogSubscriber.runtime;
    # note we don't do this when `keep_default_active_record_log` is enabled,
    # as ActiveRecord is already adding the duration.
    def increase_runtime_duration(event)
      return if Rails.application.config.lograge_sql.keep_default_active_record_log

      ActiveRecord::LogSubscriber.runtime += event.duration
    end
  end
end
