require 'rails_helper'
require 'stringio'

RSpec.describe Export::Invoices do
  context 'given valid invoices and an in-memory output' do
    let(:invoice)  { create(:invoice_entry) }
    let(:invoices) { [invoice, create(:invoice_entry)] }

    let(:output) { StringIO.new }
    subject(:output_lines) { output.string.split("\n") }

    before do
      Export::Invoices.new(invoices, output).run
    end

    it 'writes a header to that output' do
      expect(output_lines.first).to eql(
        'SubmissionID'
      )
    end

    it 'writes each invoice to that output' do
      expect(output_lines.length).to eql(3)
      expect(output_lines[1]).to eql(
        "#{invoice.submission_id}"
      )
    end

    it 'has as many headers as row values' do
      expect(Export::Invoices::HEADER.length).to eql(
        Export::Invoices::Row.new(invoice).row_values.length
      )
    end
  end
end
