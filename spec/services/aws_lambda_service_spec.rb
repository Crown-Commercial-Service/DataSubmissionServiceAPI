require 'rails_helper'

RSpec.describe AWSLambdaService do
  let(:subject) { described_class.new(submission_id: 'id') }
  describe '.trigger' do
    it 'invokes the calculate lambda function with the accurate params' do
      allow(ENV).to receive(:[]).with('AWS_LAMBDA_CALCULATE').and_return('test-calculate-function')
      fake_client = Aws::Lambda::Client.new(stub_responses: true)
      params = {
        function_name: 'test-calculate-function',
        invocation_type: 'Event',
        payload: { submission_id: 'id' }.to_json,
        log_type: 'Tail'
      }

      expect(subject).to receive(:client).and_return(fake_client)
      expect(fake_client).to receive(:invoke).with(params)
      response = subject.trigger

      expect(response).to eq({})
    end
  end
end
