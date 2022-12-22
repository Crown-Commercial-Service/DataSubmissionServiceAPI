require 'rails_helper'

RSpec.describe UserImportJob do
  around do |example|
    ClimateControl.modify AWS_S3_BUCKET: 'fake', AWS_S3_REGION: 'zz-north-1' do
      example.run
    end
  end

  describe '#perform' do
    before do
      Aws.config[:s3] = { stub_responses: true }
      allow(Import::Users).to receive(:new).and_return(importer_double)
    end
    
    let(:bulk_user_upload) { create(:bulk_user_upload, :with_attachment) }
    let(:importer_double) { double(run: true) }
    
    context 'given a valid csv' do
      it 'passes the user list to Import::Users' do
        expect(importer_double).to receive(:run)
        UserImportJob.perform_now(bulk_user_upload)
        expect(bulk_user_upload).to be_processed
      end
    end

    context 'given a users csv which fails to download' do
      before { stub_s3_get_object_with_exception(Timeout::Error) }

      it 'throws an error, and retries the job' do
        allow_any_instance_of(AttachedFileDownloader)
          .to receive(:download!)
          .and_raise(Aws::S3::Errors::NoSuchKey.new('fake', 'fake'))

        expect_any_instance_of(UserImportJob).to receive(:retry_job)

        UserImportJob.perform_now(bulk_user_upload)

        expect(bulk_user_upload).to be_pending
      end
    end

    it 'does not retry the job when the import raises an Import::Users::InvalidSalesforceId error' do
      allow(importer_double).to receive(:run).and_raise Import::Users::InvalidSalesforceId.new('fake')

      expect_any_instance_of(UserImportJob).not_to receive(:retry_job)
      UserImportJob.perform_now(bulk_user_upload)
      expect(bulk_user_upload).to be_failed
    end

    it 'does not retry the job when the import raises an Import::Users::InvalidFormat error' do
      allow(importer_double).to receive(:run).and_raise Import::Users::InvalidFormat.new('fake')

      expect_any_instance_of(UserImportJob).not_to receive(:retry_job)
      UserImportJob.perform_now(bulk_user_upload)
      expect(bulk_user_upload).to be_failed
    end

    it 'retries when the import raises a Aws::S3::Errors::ServiceError' do
      s3_client = double
      allow(Aws::S3::Client).to receive(:new).and_return s3_client
      allow(s3_client).to receive(:get_object).and_raise Aws::S3::Errors::ServiceError.new('fake', 'fake')
      allow(s3_client).to receive(:delete_object).and_return(Aws::S3::Types::DeleteObjectOutput.new)

      expect_any_instance_of(UserImportJob).to receive(:retry_job)
      UserImportJob.perform_now(bulk_user_upload)
    end
  end
end
