require 'rails_helper'

RSpec.describe Framework::Definition::AST::Field do
  describe '#primitive_type' do
    subject(:primitive_type) { Framework::Definition::AST::Field.new(field_def).primitive_type }

    context 'a known field' do
      let(:field_def) do
        { kind: :known, field: 'CustomerURN', from: 'Customer URN' }
      end

      it { is_expected.to eql(:urn) }
    end

    context 'an additional field' do
      context 'with a primitive type' do
        let(:field_def) do
          {
            kind: :additional,
            optional: true,
            type:  'String',
            field: 'Additional3',
            from:  'Subcontractor Supplier Name'
          }
        end

        it { is_expected.to eql(:string) }
      end

      context 'with a lookup type' do
        let(:field_def) do
          {
            kind: :additional,
            optional: true,
            type:  'PaymentProfile',
            field: 'Additional2',
            from:  'Payment Profile'
          }
        end

        it 'always treats lookups types as :string' do
          expect(primitive_type).to eql(:string)
        end
      end
    end

    context 'an unknown field' do
      let(:field_def) do
        { kind: :unknown, optional: true, type: 'String', from: 'Cost Centre' }
      end

      it { is_expected.to eql(:string) }
    end
  end
end
