require 'rails_helper'

RSpec.describe IngestPostProcessor do
  let(:framework) { FactoryBot.create(:framework, short_name: 'RM3756') }
  let(:processor) { IngestPostProcessor.new(params: params, framework: framework) }

  describe '#total_value' do
    subject(:total_value) { processor.total_value }

    context 'given parameters for an "invoice" submission entry' do
      let(:params) { { entry_type: 'invoice', data: { 'Total Cost (ex VAT)' => 12.34 } } }

      it 'extracts the total value from the data field specified in the framework definition' do
        expect(total_value).to eql(12.34)
      end
    end

    context 'given parameters for an "order" submission entry' do
      let(:params) { { entry_type: 'order', data: { 'Expected Total Order Value' => 66 } } }

      it 'extracts the total value from the data field specified in the framework definition' do
        expect(total_value).to eql(66)
      end
    end
  end

  describe '#resolved_parameters' do
    let(:params) { { entry_type: 'invoice', data: { 'Total Cost (ex VAT)' => 12.34 } } }

    it 'returns the passed-in parameters merged with the extra extracted attributes' do
      resolved_params = processor.resolve_parameters

      expect(resolved_params).to eq params.merge(total_value: 12.34)
    end
  end
end
