# frozen_string_literal: true

RSpec.describe Lograge::ActiveRecordLogSubscriber do
  describe '#sql' do
    subject(:log_subscriber) { described_class.new }
    let(:event) { instance_double('ActiveSupport::Notification::Event.new', duration: 20, payload: {}) }
    let(:rails) { double('rails') }
    let(:ar_runtime_registry) { double('ActiveRecord::RuntimeRegistry', sql_runtime: 100.0) }

    before do
      stub_const('Rails', rails)
      stub_const('ActiveRecord::RuntimeRegistry', ar_runtime_registry)
      Lograge::Sql.extract_event = proc {}
      Lograge::Sql.store.clear
    end

    context 'with keep_default_active_record_log not set' do
      before do
        allow(Rails).to receive_message_chain('application.config.lograge_sql.keep_default_active_record_log') { nil }
      end

      context 'when ActiveRecord::RuntimeRegistry responds to :stats' do
        let(:stats) { double('stats', sql_runtime: 100.0) }

        before do
          allow(ar_runtime_registry).to receive(:respond_to?).with(:stats).and_return(true)
          allow(ar_runtime_registry).to receive(:stats).and_return(stats)
        end

        it 'adds duration to ActiveRecord::RuntimeRegistry.stats.sql_runtime' do
          expect(stats).to receive(:sql_runtime=).with(120.0)

          log_subscriber.sql(event)
        end
      end

      context 'when ActiveRecord::RuntimeRegistry does not respond to :stats' do
        before do
          allow(ar_runtime_registry).to receive(:respond_to?).with(:stats).and_return(false)
        end

        it 'adds duration to ActiveRecord::RuntimeRegistry sql_runtime' do
          expect(ar_runtime_registry).to receive(:sql_runtime=).with(120.0)

          log_subscriber.sql(event)
        end
      end
    end

    context 'with keep_default_active_record_log set to true' do
      before do
        allow(Rails).to receive_message_chain('application.config.lograge_sql.keep_default_active_record_log') { true }
      end

      it 'does not add duration to ActiveRecord::RuntimeRegistry sql_runtime' do
        expect(ar_runtime_registry).to_not receive(:sql_runtime=)

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

    context 'with custom filter' do
      let(:query_filter) { instance_double(Proc, call: {}) }

      before do
        allow(Rails).to receive_message_chain('application.config.lograge_sql.keep_default_active_record_log') { true }
        allow(event).to receive(:payload).and_return({ sql: 'foo' })
        Lograge::Sql.query_filter = query_filter
      end

      after do
        # reset filter after test
        Lograge::Sql.query_filter = nil
      end

      it 'apply filter to sql payload' do
        log_subscriber.sql(event)
        expect(query_filter).to have_received(:call).with('foo')
      end
    end
  end
end
