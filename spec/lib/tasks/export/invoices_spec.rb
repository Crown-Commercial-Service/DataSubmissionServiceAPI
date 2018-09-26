require 'rails_helper'

RSpec.describe 'rake export:invoices', type: :task do
  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  context 'no date is given' do
    let(:invoice_exporter)   { spy('Export::Invoices') }
    let(:invoices_to_export) { [double('Invoice'), double('Invoice')] }
    let(:todays_filename)    { "/tmp/invoices_#{Time.zone.today}.csv" }

    after { File.delete(todays_filename) }

    before do
      allow(Export::Invoices::Extract).to receive(:all_relevant).and_return(invoices_to_export)
      allow(Export::Invoices).to receive(:new).with(
        invoices_to_export, duck_type(:puts)
      ).and_return(
        invoice_exporter
      )

      task.execute
    end

    it 'forwards the request to Export::Invoices#run' do
      expect(invoice_exporter).to have_received(:run)
    end

    it 'creates that file' do
      expect(File).to exist(todays_filename)
    end

    it 'tells us what file it’s creating on STDERR' do
      expect { task.execute }.to output(
        "Exporting invoices to #{todays_filename}\n"
      ).to_stderr
    end
  end
end
