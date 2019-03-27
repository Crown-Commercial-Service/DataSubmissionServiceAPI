require 'rails_helper'

RSpec.describe Framework::Definition::AST::Field do
  let(:lookups)   { {} }
  subject(:field) { Framework::Definition::AST::Field.new(field_def, lookups) }
  let(:parser)    { Framework::Definition::Parser.new }
  let(:cst)       { parser.field_def.parse(source) }
  let(:field_def) { Framework::Definition::AST::Creator.new.apply(cst) }

  describe 'known fields' do
    context 'of a primitive type' do
      let(:source) { "CustomerURN from 'Customer URN'" }

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
      let(:source) { "PromotionCode from 'Spend Code'" }

      it { is_expected.to be_lookup }

      it 'has a lookup name the same as its warehouse name' do
        expect(field.lookup_name).to eql('PromotionCode')
      end
    end

    context 'the known field validates dependent on another field' do
      let(:lookups) do
        {
          'Lot2Segment' => ['Car Derived Van', 'LCV', 'MPV', 'Pickup'],
          'Lot3Segment' => ['HGV'],
        }
      end
      let(:source) do
        <<~FDL
          ProductGroup from 'Vehicle Segment' depends_on 'Lot Number' {
            '2' -> Lot2Segment
            '3' -> Lot3Segment
          }
        FDL
      end

      it { is_expected.to be_dependent_field_inclusion }

      it 'expands the Lot Segments out to their literal values' do
        expect(field.dependent_field_inclusion_values).to eq(
          '2' => ['Car Derived Van', 'LCV', 'MPV', 'Pickup'],
          '3' => ['HGV'],
        )
      end
    end
  end

  context 'an additional field' do
    context 'with a primitive type of String' do
      let(:source) { "optional String Additional3 from 'Subcontractor Supplier Name'" }

      it      { is_expected.not_to be_lookup }
      example { expect(field.primitive_type).to eql(:string) }
      example { expect(field.lookup_name).to be_nil }
    end

    context 'with a primitive type of Date' do
      let(:source) { "optional Date Additional10 from 'Lease Start Date'" }

      it      { is_expected.not_to be_lookup }
      example { expect(field.source_type).to eql('Date') }
      example { expect(field.primitive_type).to eql(:date) }
    end

    context 'with a lookup (non-primitive) type' do
      let(:source) { "optional PaymentProfile Additional2 from 'Payment Profile'" }

      it { is_expected.to be_lookup }
      it 'has a lookup_name' do
        expect(field.lookup_name).to eql('PaymentProfile')
      end
      it 'always treats lookups types as :string' do
        expect(field.source_type).to eql('PaymentProfile')
        expect(field.primitive_type).to eql(:string)
      end
    end

    describe '#length_options' do
      subject { field.length_options }

      context 'minimum length' do
        let(:source) { "String(3..) Additional2 from 'Payment Profile'" }
        it { is_expected.to eq(minimum: 3) }
        example { expect(field.source_type).to eql('String') }
      end

      context 'maximum length' do
        let(:source) { "String(..8) Additional2 from 'Payment Profile'" }
        it { is_expected.to eq(maximum: 8) }
      end

      context 'exact length' do
        let(:source) { "String(5) Additional2 from 'Payment Profile'" }
        it { is_expected.to eq(is: 5) }
      end

      context 'with a min and a max' do
        let(:source) { "String(5..10) Additional2 from 'Payment Profile'" }
        it { is_expected.to eq(in: 5..10) }
      end
    end
  end

  context 'an unknown field' do
    let(:source) { "optional String from 'Cost Centre'" }

    it      { is_expected.not_to be_lookup }
    example { expect(field.source_type).to eql('String') }
    example { expect(field.primitive_type).to eql(:string) }
  end
end
