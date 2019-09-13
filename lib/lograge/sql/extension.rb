# frozen_string_literal: true

module Lograge
  module Sql
    # Module used to extend Lograge
    module Extension
      # Overrides `Lograge::RequestLogSubscriber#extract_request` do add SQL queries
      def extract_request(event, payload)
        super.merge!(extract_sql_queries)
      end

      # Collects all SQL queries stored in the Thread during request processing
      def extract_sql_queries
        sql_queries = Lograge::Sql.store[:lograge_sql_queries]
        return {} unless sql_queries

        Lograge::Sql.store[:lograge_sql_queries] = nil
        {
          sql_queries: Lograge::Sql.formatter.call(sql_queries),
          sql_queries_count: sql_queries.length
        }
      end
    end
  end
end

module Lograge
  # Log subscriber to replace ActiveRecord's default one
  class ActiveRecordLogSubscriber < ActiveSupport::LogSubscriber
    # Every time there's an SQL query, stores it into the Thread.
    # They'll later be access from the RequestLogSubscriber.
    def sql(event)
      ActiveRecord::LogSubscriber.runtime += event.duration
      return if event.payload[:name] == 'SCHEMA'

      Lograge::Sql.store[:lograge_sql_queries] ||= []
      Lograge::Sql.store[:lograge_sql_queries] << Lograge::Sql.extract_event.call(event)
    end
  end
end

if defined?(Lograge::RequestLogSubscriber)
  Lograge::RequestLogSubscriber.prepend Lograge::Sql::Extension
else
  Lograge::LogSubscribers::ActionController.prepend Lograge::Sql::Extension
end

ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
  Lograge.unsubscribe(:active_record, subscriber) if subscriber.is_a?(ActiveRecord::LogSubscriber)
end

Lograge::ActiveRecordLogSubscriber.attach_to :active_record
