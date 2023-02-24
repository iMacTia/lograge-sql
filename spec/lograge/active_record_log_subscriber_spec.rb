# frozen_string_literal: true

RSpec.describe Lograge::ActiveRecordLogSubscriber do
  describe '#sql' do
    subject(:log_subscriber) { described_class.new }
    let(:event) { instance_double('ActiveSupport::Notification::Event.new', duration: 20, payload: {}) }
    let(:rails) { double('rails') }
    let(:ar_log_subscriber) { double('ActiveRecord::LogSubscriber', runtime: 100) }

    before do
      stub_const('Rails', rails)
      stub_const('ActiveRecord::LogSubscriber', ar_log_subscriber)
      Lograge::Sql.extract_event = proc {}
      Lograge::Sql.store.clear
    end

    context 'with keep_default_active_record_log not set' do
      before do
        allow(Rails).to receive_message_chain('application.config.lograge_sql.keep_default_active_record_log') { nil }
      end

      it 'adds duration to ActiveRecord::LogSubscriber runtime' do
        expect(ar_log_subscriber).to receive(:runtime=).with(120)

        log_subscriber.sql(event)
      end
    end

    context 'with keep_default_active_record_log set to true' do
      before do
        allow(Rails).to receive_message_chain('application.config.lograge_sql.keep_default_active_record_log') { true }
      end

      it 'does not add duration to ActiveRecord::LogSubscriber runtime' do
        expect(ar_log_subscriber).to_not receive(:runtime=)

        log_subscriber.sql(event)
      end
    end

    context 'with custom min_duration_ms threshold' do
      before do
        # this is just to avoid setting too many "allows".
        allow(Rails).to receive_message_chain('application.config.lograge_sql.keep_default_active_record_log') { true }
        Lograge::Sql.min_duration_ms = 500
      end

      after do
        # reset min_duration_ms after test
        Lograge::Sql.min_duration_ms = 0
      end

      it 'does not store the event' do
        log_subscriber.sql(event)
        expect(Lograge::Sql.store[:lograge_sql_queries]).to be_nil
      end
    end
  end
end
