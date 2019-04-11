require 'rails_helper'

RSpec.describe VcapParser do
  describe '.load_service_environment_variables!' do
    it 'loads service level environment variables to the ENV' do
      vcap_json = '
        {
           "user-provided": [
            {
             "credentials": {
              "ENV1": "ENV1VALUE",
              "ENV2": "ENV2VALUE"
             }
            }
           ]
         }
      '
      ClimateControl.modify VCAP_SERVICES: vcap_json do
        VcapParser.load_service_environment_variables!
        expect(ENV['ENV2']).to eq('ENV2VALUE')
      end
    end

    it 'loads s3 bucket names to the ENV' do
      vcap_json = '
        {
          "aws-s3-bucket": [
            {
              "credentials": {
                "aws_access_key_id": "WRONG",
                "aws_region": "WRONG",
                "aws_secret_access_key": "WRONG",
                "bucket_name": "WRONG"
              },
              "name": "another-bucket-production-spacename"
            },
            {
              "credentials": {
                "aws_access_key_id": "INGESTACCESSKEY",
                "aws_region": "INGESTREGION",
                "aws_secret_access_key": "INGESTACCESSKEYSECRET",
                "bucket_name": "INGESTBUCKETNAME"
              },
              "name": "ingest-bucket-production-spacename"
            }
          ]
        }
      '
      ClimateControl.modify VCAP_SERVICES: vcap_json do
        VcapParser.load_service_environment_variables!
        expect(ENV['AWS_ACCESS_KEY_ID']).to eq('INGESTACCESSKEY')
        expect(ENV['AWS_SECRET_ACCESS_KEY']).to eq('INGESTACCESSKEYSECRET')
        expect(ENV['AWS_S3_REGION']).to eq('INGESTREGION')
        expect(ENV['AWS_REGION']).to eq('INGESTREGION')
        expect(ENV['AWS_S3_BUCKET']).to eq('INGESTBUCKETNAME')
      end
    end

    it 'does not error if VCAP_SERVICES is not set' do
      ClimateControl.modify VCAP_SERVICES: nil do
        expect { VcapParser.load_service_environment_variables! }.to_not raise_error
      end
    end
  end
end
