require 'rails_helper'

RSpec.describe Framework::Definition::AST::Field do
  let(:lookups)   { {} }
  subject(:field) { Framework::Definition::AST::Field.new(field_def, lookups) }

  describe 'known fields' do
    context 'of a primitive type' do
      let(:field_def) do
        { kind: :known, field: 'CustomerURN', from: 'Customer URN' }
      end

      it      { is_expected.not_to be_lookup }
      example { expect(field.primitive_type).to eql(:urn) }
    end

    context 'the known field name matches a lookup name' do
      let(:lookups) do
        {
          'PromotionCode' => [
            'Lease Rental', 'Fleet Management Fee', 'Damage', 'Other Re-charges'
          ]
        }
      end
      let(:field_def) do
        { kind: :known, field: 'PromotionCode', from: 'Spend Code' }
      end

      it { is_expected.to be_lookup }

      it 'has a lookup name the same as its warehouse name' do
        expect(field.lookup_name).to eql('PromotionCode')
      end
    end
  end

  context 'an additional field' do
    context 'with a primitive type of String' do
      let(:field_def) do
        {
          kind: :additional,
          optional: true,
          type:  'String',
          field: 'Additional3',
          from:  'Subcontractor Supplier Name'
        }
      end

      it      { is_expected.not_to be_lookup }
      example { expect(field.primitive_type).to eql(:string) }
      example { expect(field.lookup_name).to be_nil }
    end

    context 'with a primitive type of Date' do
      let(:field_def) do
        {
          kind: :additional,
          optional: true,
          type:  'Date',
          field: 'Additional10',
          from:  'Lease Start Date'
        }
      end

      it      { is_expected.not_to be_lookup }
      example { expect(field.primitive_type).to eql(:date) }
    end

    context 'with a lookup (non-primitive) type' do
      context 'on an Additional field' do
        let(:field_def) do
          {
            kind: :additional,
            optional: true,
            type:  'PaymentProfile',
            field: 'Additional2',
            from:  'Payment Profile'
          }
        end

        it { is_expected.to be_lookup }
        it 'has a lookup_name' do
          expect(field.lookup_name).to eql('PaymentProfile')
        end
        it 'always treats lookups types as :string' do
          expect(field.primitive_type).to eql(:string)
        end
      end
    end
  end

  context 'an unknown field' do
    let(:field_def) do
      { kind: :unknown, optional: true, type: 'String', from: 'Cost Centre' }
    end

    it      { is_expected.not_to be_lookup }
    example { expect(field.primitive_type).to eql(:string) }
  end
end
