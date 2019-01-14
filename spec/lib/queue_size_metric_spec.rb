require 'rails_helper'
require 'queue_size_metric'

RSpec.describe QueueSizeMetric do
  describe '#publish' do
    it 'puts the Sidekiq queue size as a CloudWatch Metric, namespaced with the Rails environment' do
      stub_sidekiq_stats

      metric = QueueSizeMetric.new(stub_responses: true)
      metric.publish
      executed_request = metric.aws_client.api_requests[0]

      expect(executed_request[:operation_name]).to eq :put_metric_data
      expect(executed_request[:params][:namespace]).to eq "api-worker-#{Rails.env}"
      expect(executed_request[:params][:metric_data][0][:metric_name]).to eq 'Queue Size'
      expect(executed_request[:params][:metric_data][0][:value]).to eq Sidekiq::Stats.new.enqueued
    end
  end

  def stub_sidekiq_stats
    allow_any_instance_of(Sidekiq::Stats).to receive(:enqueued).and_return(23)
    allow_any_instance_of(Sidekiq::Stats).to receive(:fetch_stats!)
  end
end
