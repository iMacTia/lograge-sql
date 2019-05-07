# frozen_string_literal: true

require 'spec_helper'

describe Lograge::Sql do
  let(:subscriber) do
    if defined?(Lograge::RequestLogSubscriber)
      Lograge::RequestLogSubscriber
    else
      Lograge::LogSubscribers::ActionController
    end
  end

  it 'has a version number' do
    expect(Lograge::Sql::VERSION).not_to be nil
  end

  it 'extends lograge' do
    require 'lograge/sql/extension'

    expect(subscriber.new).to respond_to(:extract_sql_queries)
  end
end
