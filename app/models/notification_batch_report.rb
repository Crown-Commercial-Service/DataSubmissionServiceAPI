require 'csv'

class NotificationBatchReport
  HEADER = [
    'email address',
    'supplier name',
    'status',
    'sent at',
    'completed at',
    'notify id',
    'error'
  ].freeze

  def initialize(batch:, output:)
    @batch = batch
    @output = output
  end

  def generate
    output.puts CSV.generate_line(HEADER)

    batch.notification_deliveries.order(:email).find_each do |delivery|
      output.puts CSV.generate_line([
        delivery.email,
        delivery.supplier_name,
        delivery.status,
        delivery.sent_at,
        delivery.completed_at,
        delivery.notify_id,
        delivery.error_message
      ])
    end
  end

  private

  attr_reader :batch, :output
end
