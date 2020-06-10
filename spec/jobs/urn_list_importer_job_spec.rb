require 'rails_helper'

RSpec.describe UrnListImporterJob do
  around do |example|
    ClimateControl.modify AWS_S3_BUCKET: 'fake', AWS_S3_REGION: 'zz-north-1' do
      example.run
    end
  end

  describe '#perform' do
    before { stub_s3_get_object('customers.xlsx') }

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

      it 'soft deletes obsolete customer records' do
        customer = create(:customer, urn: 10009656, name: 'Deleted organisation')

        UrnListImporterJob.perform_now(urn_list)

        customer.reload

        expect(customer.urn).to eql 10009656
        expect(customer.name).to eql 'Deleted organisation'
        expect(customer).to be_deleted
        expect(urn_list).to be_processed
      end

      it 'restores a previously deleted customer now back in the list' do
        customer = create(:customer,
                          urn: 10009655,
                          deleted: true,
                          name: 'Crown Commercial Service')

        UrnListImporterJob.perform_now(urn_list)

        customer.reload

        expect(customer.urn).to eql 10009655
        expect(customer.name).to eql 'Crown Commercial Service'
        expect(customer).not_to be_deleted
        expect(urn_list).to be_processed
      end
    end

    context 'given a URN list which fails to download' do
      before { stub_s3_get_object_with_exception(Timeout::Error) }

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
      before { stub_s3_get_object('customers_with_wrong_sheet_name.xlsx') }

      let(:urn_list) { create(:urn_list, filename: 'customers_with_wrong_sheet_name.xlsx') }

      it 'throws an error, and is not retried' do
        expect_any_instance_of(UrnListImporterJob).not_to receive(:retry_job)

        UrnListImporterJob.perform_now(urn_list)

        expect(urn_list).to be_failed
      end
    end

    context 'given a URN list without the required columns' do
      before { stub_s3_get_object('customers_with_missing_columns.xlsx') }

      let(:urn_list) { create(:urn_list, filename: 'customers_with_missing_columns.xlsx') }

      it 'throws an error, and is not retried' do
        expect_any_instance_of(UrnListImporterJob).not_to receive(:retry_job)

        UrnListImporterJob.perform_now(urn_list)

        expect(urn_list).to be_failed
      end
    end
  end
end
