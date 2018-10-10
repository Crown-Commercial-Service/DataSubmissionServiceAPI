require 'rails_helper'

RSpec.describe IngestPostProcessor do
  describe '#resolved_parameters' do
    it 'extracts the relevant fields from the data parameter for an invoice entry and sets the total_value' do
      framework = create(:framework, short_name: 'RM3756')
      submission = create(:submission, framework: framework)

      params = ActionController::Parameters.new(
        submission_id: submission.id,
        entry_type: 'invoice',
        data: {
          'Total Cost (ex VAT)': 12.34
        }
      )

      resolved_params = IngestPostProcessor.new(params: params, framework: framework).resolve_parameters

      expect(resolved_params[:total_value]).to eql(12.34)
    end

    it 'extracts the relevant fields from the data parameter for an order entry and sets the total_value' do
      framework = create(:framework, short_name: 'RM3756')
      submission = create(:submission, framework: framework)

      params = ActionController::Parameters.new(
        submission_id: submission.id,
        entry_type: 'order',
        data: {
          'Expected Total Order Value': -1234.56
        }
      )

      resolved_params = IngestPostProcessor.new(params: params, framework: framework).resolve_parameters

      expect(resolved_params[:total_value]).to eql(-1234.56)
    end
  end
end
