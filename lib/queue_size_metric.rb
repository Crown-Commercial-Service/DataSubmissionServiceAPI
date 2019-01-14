require 'aws-sdk-cloudwatch'

class QueueSizeMetric
  attr_reader :aws_client

  def initialize(aws_client_options = {})
    @aws_client = Aws::CloudWatch::Client.new(aws_client_options)
  end

  def publish
    @aws_client.put_metric_data(
      namespace: "api-worker-#{Rails.env}",
      metric_data: [{
        metric_name: 'Queue Size',
        timestamp: Time.zone.now,
        value: queue_size,
        unit: 'Count'
      }]
    )
  end

  private

  def queue_size
    Sidekiq::Stats.new.enqueued
  end
end
