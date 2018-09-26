require 'rails_helper'
require 'stringio'

RSpec.describe Export::Invoices do
  context 'given some invoices and an in-memory output' do
    let!(:complete_submission) do
      create :submission,
             aasm_state: 'completed',
             framework: create(:framework, short_name: 'RM3786')
    end

    let!(:invoice) do
      create :invoice_entry, :legal_framework_data, submission: complete_submission
    end

    let!(:invoice2) { create(:invoice_entry, submission: complete_submission) }

    let(:output)             { StringIO.new }
    let(:extracted_invoices) { Export::Invoices::Extract.all_relevant }

    subject(:output_lines) { output.string.split("\n") }

    before do
      Export::Invoices.new(extracted_invoices, output).run
    end

    it 'writes a header to that output' do
      expect(output_lines.first).to eql(
        'SubmissionID,CustomerURN,CustomerName,CustomerPostcode,InvoiceDate,InvoiceNumber,'\
        'SupplierReferenceNumber,CustomerReferenceNumber,LotNumber,ProductDescription,'\
        'ProductGroup,ProductClass,ProductSubClass,ProductCode,UnitType,UnitPrice,UnitQuantity,'\
        'InvoiceValue,Expenses,VATCharged,PromotionCode,'\
        'Additional1,Additional2,Additional3,Additional4,Additional5,Additional6,Additional7,Additional8'
      )
    end

    it 'writes each invoice to that output' do
      expect(output_lines.length).to eql(3)
      expect(output_lines[1]).to eql(
        "#{invoice.submission_id},10012345,Department for Education,SW1P 3ZZ,5/31/18,3307957,DEP/0008.00032,,1,"\
        '#MISSING,#MISSING,#MISSING,#MISSING,#MISSING,Hourly,151.09,-0.9,-135.98,,-27.20,'\
        ',GITIS Terms and Conditions,0.00,0.00,0.00,N/A,Time and Material,,'
      )
    end

    it 'writes #NOTINDATA for fields it cannot map' do
      expect(output_lines[2]).to eql(
        "#{invoice.submission_id},#NOTINDATA,#NOTINDATA,#NOTINDATA,#NOTINDATA,#NOTINDATA,#NOTINDATA,,#NOTINDATA,"\
        '#MISSING,#MISSING,#MISSING,#MISSING,#MISSING,#NOTINDATA,#NOTINDATA,#NOTINDATA,#NOTINDATA,,#NOTINDATA,'\
        ',,,,,,,,'
      )
    end

    it 'has as many headers as row values' do
      expect(Export::Invoices::HEADER.length).to eql(
        Export::Invoices::Row.new(extracted_invoices.first).row_values.length
      )
    end
  end
end
