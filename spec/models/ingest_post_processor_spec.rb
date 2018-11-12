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

    context 'given parameters with invalid characters' do
      let(:params) { { entry_type: 'invoice', data: { 'Total Cost (ex VAT)' => ' -£ 12,345.67 xxx ' } } }

      it 'removes those values when extracting the total value from the data field' do
        expect(total_value).to eql(-12345.67)
      end
    end
  end

  describe '#customer_urn' do
    let(:customer) { FactoryBot.create(:customer) }
    subject(:customer_urn) { processor.customer_urn }

    context 'given parameters for an "invoice" submission entry' do
      let(:params) { { entry_type: 'invoice', data: { 'Customer URN' => customer.urn } } }

      it 'extracts the customer URN from the data field specified in the framework definition export mapping' do
        expect(customer_urn).to eql customer.urn
      end
    end

    context 'given parameters for an "order" submission entry' do
      let(:params) { { entry_type: 'order', data: { 'Customer URN' => customer.urn } } }

      it 'extracts the customer URN from the data field specified in the framework definition export mapping' do
        expect(customer_urn).to eql customer.urn
      end
    end

    context 'given a URN that doesn’t match any known customers' do
      let(:params) { { entry_type: 'invoice', data: { 'Customer URN' => '000000' } } }

      it 'returns nil instead of the duff customer URN' do
        expect(customer_urn).to be_nil
      end
    end
  end

  describe '#resolved_parameters' do
    let(:customer) { FactoryBot.create(:customer) }
    let(:params) { { entry_type: 'invoice', data: { 'Customer URN' => customer.urn, 'Total Cost (ex VAT)' => 12.34 } } }

    it 'returns the passed-in parameters merged with the extra extracted attributes' do
      resolved_params = processor.resolve_parameters

      expected_extra_attributes = {
        customer_urn: customer.urn,
        total_value: 12.34
      }

      expect(resolved_params).to eq params.merge(expected_extra_attributes)
    end
  end
end
