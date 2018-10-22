require 'rails_helper'

RSpec.describe Framework::Definition do
  describe '.[]' do
    subject(:definition) { Framework::Definition[framework_short_name] }

    context 'the framework exists' do
      context 'and it is fairly normal' do
        let(:framework_short_name) { 'RM3787' }
        it 'returns that framework' do
          expect(definition.framework_short_name).to eql(framework_short_name)
        end

        it 'reports the management charge' do
          expect(definition.management_charge_rate).to eq(BigDecimal('1.5'))
        end
      end

      context 'and it has slashes in it' do
        let(:framework_short_name) { 'CM/OSG/05/3565' }
        it 'returns that framework' do
          expect(definition.framework_short_name).to eql(framework_short_name)
        end

        it 'reports the management charge' do
          expect(definition.management_charge_rate).to eq(BigDecimal('0'))
        end
      end
    end

    context 'the framework does not exist' do
      it 'raises a Framework::Definition::MissingError' do
        expect { Framework::Definition['RM1234'] }.to raise_error(
          Framework::Definition::MissingError, 'Please run rails g framework:definition "RM1234"'
        )
      end
    end
  end

  describe '.all' do
    it 'gets everything that is descended from Framework::Definition::Base and nothing else' do
      expect(Framework::Definition.all.length).to be > 0
      expect(Framework::Definition.all).to all(satisfy { |c| c.ancestors.include?(Framework::Definition::Base) })
    end
  end

  describe 'Base.management_charge' do
    it 'returns the management charge based on the framework’s management charge rate, rounded to 4 decimal places' do
      expect(Framework::Definition::RM3756.management_charge(BigDecimal('102123.23'))).to eq BigDecimal('1531.8484')
      expect(Framework::Definition::RM1070.management_charge(BigDecimal('102123.23'))).to eq BigDecimal('510.6161')
      expect(Framework::Definition::CM_OSG_05_3565.management_charge(BigDecimal('102123.23'))).to eq BigDecimal('0')
    end
  end

  describe 'Base.for_entry_type' do
    it 'returns the framework’s Invoice definition for an ‘invoice’ entry_type' do
      expect(Framework::Definition::RM3756.for_entry_type('invoice')).to eq Framework::Definition::RM3756::Invoice
    end

    it 'returns the framework’s Order definition for an ‘order’ entry_type' do
      expect(Framework::Definition::RM3756.for_entry_type('order')).to eq Framework::Definition::RM3756::Order
    end
  end
end
