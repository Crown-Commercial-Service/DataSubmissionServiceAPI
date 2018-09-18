require 'rails_helper'

RSpec.describe Export::Submissions::Row do
  let(:submission) { double('Submission') }

  let(:row) { Export::Submissions::Row.new(submission) }

  describe '#status' do
    subject!(:status) { row.status }

    context 'the submission state is completed' do
      let(:submission) { double 'Submission', aasm_state: 'completed' }
      it { is_expected.to eql('supplier_accepted') }
    end

    context 'the submission state is validation_failed' do
      let(:submission) { double 'Submission', aasm_state: 'validation_failed' }
      it { is_expected.to eql('validation_failed') }
    end

    context 'the submission state is not one that should be in the output at all' do
      let(:submission) { double 'Submission', aasm_state: 'in_review' }
      it { is_expected.to eql('#ERROR') }

      it 'adds the error to a hash' do
        expect(row.errors['Status']).to eql(['in_review is not mapped to Submission column Status'])
      end
    end
  end

  describe '#submission_type and its dependence on _ projected fields' do
    before do
      allow(row).to receive(:invoice_entry_count).and_return(invoices)
      allow(row).to receive(:order_entry_count).and_return(orders)
    end

    subject { row.submission_type }

    context 'there are no invoices or order entries' do
      let(:invoices) { 0 }
      let(:orders) { 0 }
      it { is_expected.to eql('no_business') }
    end

    context 'there is at least one invoice entry' do
      let(:invoices) { 1 }
      let(:orders) { 0 }
      it { is_expected.to eql('file') }
    end

    context 'there is at least one order entry' do
      let(:invoices) { 0 }
      let(:orders) { 1 }
      it { is_expected.to eql('file') }
    end
  end

  describe '#submission_file_type' do
    let(:submission) { double 'Submission', _first_filename: 'it-is-an.XLS' }
    subject { row.submission_file_type }
    it { is_expected.to eql('xls') }
  end

  describe '#management_charge_value' do
    let(:submission) { double 'Submission', management_charge: 450.00 }
    subject { row.management_charge_value }
    it { is_expected.to eql(450.00) }
  end

  describe '#management_charge_rate' do
    subject { row.management_charge_value }
    it 'is fixed to a constant at present, expected to change Oct 2018' do
      expect(row.management_charge_rate).to eql(BigDecimal('1.5'))
    end
  end

  describe '#created_date' do
    let(:submission) { double 'Submission', created_at: Time.zone.local(2018, 9, 18, 14, 20, 35) }
    it 'is an ISO8601 date/time in UTC' do
      expect(row.created_date).to eql('2018-09-18T14:20:35Z')
    end
  end

  describe 'the fields that are absent for MVP' do
    describe '#created_by' do
      subject { row.created_by }
      it { is_expected.to be_nil }
    end

    describe '#supplier_approved_date' do
      subject { row.supplier_approved_date }
      it { is_expected.to be_nil }
    end

    describe '#supplier_approved_by' do
      subject { row.supplier_approved_by }
      it { is_expected.to be_nil }
    end

    describe '#finance_export_date' do
      subject { row.finance_export_date }
      it { is_expected.to be_nil }
    end

    describe '#po_number' do
      subject { row.po_number }
      it { is_expected.to be_nil }
    end
  end
end
