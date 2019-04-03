require 'rails_helper'
require 'generators/framework/fdl_generator'

RSpec.describe Framework::FdlGenerator, type: :generator do
  let(:destination)      { Rails.root.join('tmp', 'generator_results') }
  let(:definitions_root) { 'app/models/framework/definition' }

  subject(:definition) { @definition }

  before do
    assert_file(File.join(definitions_root, expected_definition_file)) do |definition|
      @definition = definition
    end
  end

  context 'RM3786 – General Legal Services' do
    let(:generator_arguments)      { %w[RM3786] }
    let(:expected_definition_file) { 'RM3786.fdl' }

    it 'defines a framework' do
      expect(definition).to match 'Framework RM3786 {'
    end
    it 'defines a framework name' do
      expect(definition).to match "Name 'General Legal Advice Services'"
    end
    it 'defines a management charge' do
      expect(definition).to match('ManagementCharge 1.5%')
    end

    describe 'InvoiceFields' do
      it 'defines some invoice fields' do
        expect(definition).to match 'InvoiceFields {'
      end
      it 'defines present known fields' do
        expect(definition).to match "LotNumber from 'Tier Number'"
        expect(definition).to match "CustomerURN from 'Customer URN'"
      end
      it 'defines optional known and unknown fields' do
        expect(definition).to match "optional SupplierReferenceNumber from 'Supplier Reference Number'"
        expect(definition).to match "optional String from 'Cost Centre'"
      end
      it 'defines lookup-typed additional fields' do
        expect(definition).to match "PricingMechanism Additional5 from 'Pricing Mechanism'"
      end
      it 'typed additional fields' do
        expect(definition).to match "Decimal Additional1 from 'Pro-Bono Price per Unit"
      end
    end

    describe 'ContractFields' do
      it 'defines some contract fields' do
        expect(definition).to match 'ContractFields {'
      end
      it 'defines optional known fields' do
        expect(definition).to match "optional ContractStartDate from 'Contract Start Date'"
      end
      it 'types additional fields' do
        expect(definition).to match "Decimal Additional1 from 'Pro-Bono Price per Unit"
      end
      it 'types YesNo fields' do
        expect(definition).to match "YesNo Additional4 from 'Pro-bono work included?"
      end
    end
  end
  context 'RM807' do
    let(:generator_arguments)      { %w[RM807] }
    let(:expected_definition_file) { 'RM807.fdl' }

    it 'defines a framework' do
      expect(definition).to match 'Framework RM807 {'
    end
    it 'defines a management charge' do
      expect(definition).to match('ManagementCharge 0.5%')
    end

    describe 'InvoiceFields' do
      it 'defines some invoice fields' do
        expect(definition).to match 'InvoiceFields {'
      end
      it 'defines optional additional fields' do
        expect(definition).to match "optional Decimal Additional6 from 'Miles Travelled'"
      end
    end
  end
end
