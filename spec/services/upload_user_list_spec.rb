require 'rails_helper'

RSpec.describe UploadUserList do
  around do |example|
    ClimateControl.modify AWS_S3_BUCKET: 'fake', AWS_S3_REGION: 'zz-north-1' do
      example.run
    end
  end

  before do
    allow(SecureRandom).to receive(:urlsafe_base64).and_return('foofoofoo')

    Aws.config[:s3] = { stub_responses: true }
  end

  describe '#call' do
    it 'uploads the file to S3 and returns the key' do
      user_list_path = Rails.root.join('spec', 'fixtures', 'users.csv').to_s

      expect(described_class.new(user_list_path).call).to eq('foofoofoo-users.csv')
    end

    it 'raises an error when something goes wrong' do
      allow_any_instance_of(Aws::S3::Object).to receive(:upload_file).and_return(false)

      user_list_path = Rails.root.join('spec', 'fixtures', 'users.csv').to_s

      expect { described_class.new(user_list_path).call }.to raise_error UploadUserList::UploadError
    end

    it 'raises an error when a file split into parts does not upload' do
      s3_upload_error = Aws::S3::MultipartUploadError.new('error', [])

      allow_any_instance_of(Aws::S3::Object).to receive(:upload_file).and_raise(s3_upload_error)

      user_list_path = Rails.root.join('spec', 'fixtures', 'users.csv').to_s

      expect { described_class.new(user_list_path).call }.to raise_error s3_upload_error
    end
  end
end
