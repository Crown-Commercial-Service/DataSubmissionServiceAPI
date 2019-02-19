require 'rails_helper'

RSpec.describe 'rake export:invoices', type: :task do
  let!(:complete_submission) do
    create :submission,
           aasm_state: 'completed',
           framework: create(:framework, short_name: 'RM3786')
  end

  let!(:invoice) do
    # Explicit times are necessary because Export::Invoices::Extract.all_relevant
    # relies on order(:created_date)
    create :invoice_entry, :legal_framework_invoice_data, submission: complete_submission,
                                                          management_charge: 142.99,
                                                          created_at: Time.zone.local(2018, 12, 25, 13, 55, 59)
  end

  let!(:invoice2) do
    create :invoice_entry, submission: complete_submission,
                           created_at: Time.zone.local(2018, 12, 25, 14, 55, 59)
  end

  let(:extracted_invoices) { Export::Invoices::Extract.all_relevant }

  context 'no args are given' do
    let(:output_filename) { '/tmp/invoices_2018-12-25.csv' }
    let(:args)            { {} }
    let(:output_lines)    { File.read(output_filename).split("\n") }

    around(:example) do |example|
      travel_to(Date.new(2018, 12, 25)) { example.run }
    end

    before do
      expect(invoice.created_at).to be < invoice2.created_at,
                                    'precondition: these specs depend on created_at order'
      task.execute(args)
    end
    after { File.delete(output_filename) }

    it 'writes a header to that output' do
      expect(output_lines.first).to eql(
        'SubmissionID,CustomerURN,CustomerName,CustomerPostcode,InvoiceDate,InvoiceNumber,'\
        'SupplierReferenceNumber,CustomerReferenceNumber,LotNumber,ProductDescription,'\
        'ProductGroup,ProductClass,ProductSubClass,ProductCode,UnitType,UnitPrice,UnitQuantity,'\
        'InvoiceValue,Expenses,VATCharged,PromotionCode,ManagementChargeValue,'\
        'Additional1,Additional2,Additional3,Additional4,Additional5,Additional6,Additional7,Additional8,'\
        'Additional9,Additional10,Additional11,Additional12,Additional13,Additional14,Additional15,Additional16,'\
        'Additional17,Additional18,Additional19,Additional20,Additional21,Additional22,Additional23,Additional24'
      )
    end

    it 'writes each invoice to that output' do
      expect(output_lines.length).to eql(3)
      expect(output_lines).to include(
        "#{invoice.submission_id},10012345,Department for Education,SW1P 3ZZ,2018-05-31,3307957,DEP/0008.00032,"\
        'GITIS Terms and Conditions,1,Contracts,Core,,Legal Director/Senior Solicitor,,Hourly,151.09,-0.9,-135.98,,'\
        '-27.2,,142.99,0.00,0.00,0.00,N/A,Time and Material,,,,,,,,,,,,,,,,,,,'
      )
    end

    it 'writes #NOTINDATA for fields it cannot map' do
      expect(output_lines.find { |l| l.match 'NOTINDATA' }).to eql(
        "#{invoice.submission_id},#NOTINDATA,#NOTINDATA,#NOTINDATA,#NOTINDATA,#NOTINDATA,,,,"\
        ',,,,,#NOTINDATA,#NOTINDATA,#NOTINDATA,#NOTINDATA,,#NOTINDATA,,'\
        ',,,,,,,,,,,,,,,,,,,,,,,,'
      )
    end

    it 'has as many headers as row values' do
      expect(Export::Invoices::HEADER.length).to eql(
        Export::Invoices::Row.new(extracted_invoices.first).row_values.length
      )
    end
  end
end
