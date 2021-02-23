# frozen_string_literal: true

require 'lograge/active_record_log_subscriber'

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
        if Lograge::Sql.counter_only
          lograge_sql_queries_count = Lograge::Sql.store[:lograge_sql_queries_count]
          return {} unless lograge_sql_queries_count

          Lograge::Sql.store[:lograge_sql_queries_count] = nil
          {
            sql_queries_count: lograge_sql_queries_count
          }
        else
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
end

if defined?(Lograge::RequestLogSubscriber)
  Lograge::RequestLogSubscriber.prepend Lograge::Sql::Extension
else
  Lograge::LogSubscribers::ActionController.prepend Lograge::Sql::Extension
end
