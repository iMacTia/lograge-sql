# frozen_string_literal: true

module Lograge
  # Log subscriber to replace ActiveRecord's default one
  class ActiveRecordLogSubscriber < ActiveSupport::LogSubscriber
    # Every time there's an SQL query, stores it into the Thread.
    # They'll later be access from the RequestLogSubscriber.
    def sql(event)
      increase_runtime_duration(event)
      return if event.payload[:name] == 'SCHEMA'

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
