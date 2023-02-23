# frozen_string_literal: true

module Lograge
  # Log subscriber to replace ActiveRecord's default one
  class ActiveRecordLogSubscriber < ActiveSupport::LogSubscriber
    # Every time there's an SQL query, stores it into the Thread.
    # They'll later be access from the RequestLogSubscriber.
    def sql(event)
      ActiveRecord::LogSubscriber.runtime += event.duration
      return if event.payload[:name] == 'SCHEMA'

      # Only store SQL events if `event.duration` greater than +limit_duration+ configured
      # Do not need to check +limit_duration+ present before
      return if event.duration.to_f.round(2) < Lograge::Sql.limit_duration.to_f

      Lograge::Sql.store[:lograge_sql_queries] ||= []
      Lograge::Sql.store[:lograge_sql_queries] << Lograge::Sql.extract_event.call(event)
    end
  end
end
