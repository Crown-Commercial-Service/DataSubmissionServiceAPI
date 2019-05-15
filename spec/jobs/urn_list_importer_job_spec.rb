require 'rails_helper'

RSpec.describe UrnListImporterJob do
  describe '#perform' do
    let(:urn_list) { create(:urn_list, filename: 'customers.xlsx') }

    context 'given a well-formed URN list in Excel format' do
      it 'inserts all customers' do
        expect { UrnListImporterJob.perform_now(urn_list) }
          .to change { Customer.count }
          .by(2)

        expect(urn_list).to be_processed
      end

      it 'replaces customers that already exist' do
        customer = create(:customer, urn: 10009655, name: 'CCS')

        UrnListImporterJob.perform_now(urn_list)

        customer.reload

        expect(customer.urn).to eql 10009655
        expect(customer.name).to eql 'Crown Commercial Service'
        expect(customer.postcode).to eql 'L3 9PP'
        expect(customer.sector).to eql 'central_government'
        expect(urn_list).to be_processed
      end
    end

    context 'given a URN list which fails to download' do
      let(:urn_list) { create(:urn_list, filename: 'customers.xlsx') }

      it 'throws an error, and retries the job' do
        allow_any_instance_of(AttachedFileDownloader)
          .to receive(:download!)
          .and_raise(Aws::S3::Errors::NoSuchKey.new('fake', 'fake'))

        expect_any_instance_of(UrnListImporterJob).to receive(:retry_job)

        UrnListImporterJob.perform_now(urn_list)

        expect(urn_list).to be_pending
      end
    end

    context 'given a URN list without the required sheet present' do
      let(:urn_list) { create(:urn_list, filename: 'customers_with_wrong_sheet_name.xlsx') }

      it 'throws an error, and is not retried' do
        expect_any_instance_of(UrnListImporterJob).not_to receive(:retry_job)

        UrnListImporterJob.perform_now(urn_list)

        expect(urn_list).to be_failed
      end
    end

    context 'given a URN list without the required columns' do
      let(:urn_list) { create(:urn_list, filename: 'customers_with_missing_columns.xlsx') }

      it 'throws an error, and is not retried' do
        expect_any_instance_of(UrnListImporterJob).not_to receive(:retry_job)

        UrnListImporterJob.perform_now(urn_list)

        expect(urn_list).to be_failed
      end
    end
  end
end
