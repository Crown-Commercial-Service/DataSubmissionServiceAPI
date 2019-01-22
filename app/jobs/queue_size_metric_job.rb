require 'queue_size_metric'

class QueueSizeMetricJob < ApplicationJob
  def perform
    QueueSizeMetric.new(
      region: ENV['AWS_S3_REGION']
    ).publish
  end
end
