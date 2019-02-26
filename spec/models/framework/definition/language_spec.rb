require 'rails_helper'

RSpec.describe Framework::Definition::Language do
  describe '.generate_framework_definition' do
    subject(:definition) { Framework::Definition::Language.generate_framework_definition(source) }

    context 'we have some valid FDL' do
      let(:source) do
        <<~FDL
          Framework CM/05/3769 {
            Name 'Laundry Services - Wave 2'
            ManagementCharge 0.0%
          }
        FDL
      end

      it 'is a Framework::Definition::Base' do
        expect(definition.ancestors).to include(Framework::Definition::Base)
      end

      it 'has the expected framework_short_name' do
        expect(definition.framework_short_name).to eq('CM/05/3769')
      end

      it 'has the expected framework name' do
        expect(definition.framework_name).to eq('Laundry Services - Wave 2')
      end

      it 'has the expected management charge percentage' do
        expect(definition.management_charge_rate.percentage).to eq(BigDecimal(0))
      end
    end
  end
end
