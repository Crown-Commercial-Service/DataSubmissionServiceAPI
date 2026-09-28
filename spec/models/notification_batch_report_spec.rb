require 'rails_helper'
require 'stringio'
require 'csv'

RSpec.describe NotificationBatchReport do
  subject(:generate_report) do
    described_class.new(
      batch: batch,
      output: output
    ).generate
  end

  let(:output) { StringIO.new }

  let(:batch) do
    NotificationBatch.create!(
      notification_type: 'due',
      template_id: 'template-id',
      status: 'submitted',
      started_at: Time.current
    )
  end

  before do
    batch.notification_deliveries.create!(
      email: 'alice@example.com',
      supplier_name: 'Supplier A',
      reference: 'reference a',
      notify_id: 'notify-a',
      status: 'delivered',
      sent_at: Time.zone.parse('2026-09-23T10:00:00Z'),
      completed_at: Time.zone.parse('2026-09-23T10:01:00Z')
    )

    batch.notification_deliveries.create!(
      email: 'bob@example.com',
      supplier_name: 'Supplier B',
      reference: 'reference b',
      notify_id: 'notify-b',
      status: 'permanent-failure',
      sent_at: Time.zone.parse('2026-09-23T10:00:00Z'),
      completed_at: Time.zone.parse('2026-09-23T10:02:00Z')
    )
  end

  it 'generates the expected header' do
    generate_report

    rows = CSV.parse(output.string)

    expect(rows.first).to eq(
      [
        'email address',
        'supplier name',
        'status',
        'sent at',
        'completed at',
        'notify id',
        'error'
      ]
    )
  end

  it 'includes successfully delivered notifications' do
    generate_report

    rows = CSV.parse(output.string)

    expect(rows.flatten).to include(
      'alice@example.com',
      'Supplier A',
      'notify-a',
      'delivered'
    )
  end

  it 'includes failed notifications' do
    generate_report

    rows = CSV.parse(output.string)

    expect(rows.flatten).to include(
      'bob@example.com',
      'Supplier B',
      'notify-b',
      'permanent-failure'
    )
  end

  it 'includes request errors' do
    failed_delivery = batch.notification_deliveries.find_by!(
      email: 'bob@example.com'
    )

    failed_delivery.update!(
      status: 'request-failed',
      error_message: 'Bad request'
    )

    generate_report

    expect(CSV.parse(output.string).flatten)
      .to include('request-failed', 'Bad request')
  end
end