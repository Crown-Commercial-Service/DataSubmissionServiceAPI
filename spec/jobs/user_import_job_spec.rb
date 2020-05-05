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
      allow(Import::Users).to receive(:new).and_return(importer)
    end

    let(:importer) { double('User Importer') }

    it 'passes the user list to Import::Users' do
      allow(importer).to receive(:run).and_return true

      expect(importer).to receive(:run)
      UserImportJob.perform_now('users.csv')
    end

    it 'deletes the user list from S3 after importing' do
      allow(importer).to receive(:run).and_return true

      expect_any_instance_of(Aws::S3::Client).to receive(:delete_object)

      UserImportJob.perform_now('users.csv')
    end

    it 'does not retry the job when the import raises an Import::Users::InvalidSalesforceId error' do
      allow(importer).to receive(:run).and_raise Import::Users::InvalidSalesforceId.new('fake')

      expect_any_instance_of(UserImportJob).not_to receive(:retry_job)
      expect_any_instance_of(Aws::S3::Client).not_to receive(:delete_object)
      expect(Rollbar).to receive(:info)

      UserImportJob.perform_now('user.csv')
    end

    it 'retries when the import raises a Aws::S3::Errors::ServiceError' do
      s3_client = double
      allow(Aws::S3::Client).to receive(:new).and_return s3_client
      allow(s3_client).to receive(:get_object).and_raise Aws::S3::Errors::ServiceError.new('fake', 'fake')
      allow(s3_client).to receive(:delete_object).and_return(Aws::S3::Types::DeleteObjectOutput.new)

      expect_any_instance_of(UserImportJob).to receive(:retry_job)
      expect_any_instance_of(Aws::S3::Client).not_to receive(:delete_object)

      UserImportJob.perform_now('user.csv')
    end
  end
end
