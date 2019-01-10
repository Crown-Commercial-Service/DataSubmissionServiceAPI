require 'queue_size_metric'

class QueueSizeMetricJob < ApplicationJob
  def perform
    QueueSizeMetric.new(
      region: ENV['AWS_S3_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    ).publish
  end
end
