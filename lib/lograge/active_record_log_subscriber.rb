# frozen_string_literal: true

module Lograge
  # Log subscriber to replace ActiveRecord's default one
  class ActiveRecordLogSubscriber < ActiveSupport::LogSubscriber
    # Every time there's an SQL query, stores it into the Thread.
    # They'll later be access from the RequestLogSubscriber.
    def sql(event)
      ActiveRecord::LogSubscriber.runtime += event.duration
      return if event.payload[:name] == 'SCHEMA'

      if Lograge::Sql.counter_only
        Lograge::Sql.store[:lograge_sql_queries_count] ||= 0
        Lograge::Sql.store[:lograge_sql_queries_count] += 1
      else
        Lograge::Sql.store[:lograge_sql_queries] ||= []
        Lograge::Sql.store[:lograge_sql_queries] << Lograge::Sql.extract_event.call(event)
      end
    end
  end
end
