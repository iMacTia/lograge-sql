module Lograge
  class RequestLogSubscriber
    def sql(event)
      ActiveRecord::LogSubscriber.runtime += event.duration
      return if event.payload[:name] == 'SCHEMA'
      Thread.current[:lograge_sql_queries] ||= []
      Thread.current[:lograge_sql_queries] << ("#{event.payload[:name]} (#{event.duration.to_f.round(2)}) #{event.payload[:sql]}")
    end

    alias_method :old_extract_request, :extract_request
    def extract_request(event, payload)
      data = old_extract_request(event, payload)
      data.merge!(extract_sql_queries)
    end

    def extract_sql_queries
      sql_queries = Thread.current[:lograge_sql_queries]
      return {} unless sql_queries

      Thread.current[:lograge_sql_queries] = nil
      { sql_queries: %('#{sql_queries.join("\n")}') }
    end
  end
end

ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
  Lograge.unsubscribe(:active_record, subscriber) if subscriber.is_a?(ActiveRecord::LogSubscriber)
end

Lograge::RequestLogSubscriber.attach_to :active_record