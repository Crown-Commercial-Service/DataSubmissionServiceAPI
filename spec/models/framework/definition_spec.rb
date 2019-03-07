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
      end

      context 'and it has slashes in it' do
        let(:framework_short_name) { 'CM/OSG/05/3565' }
        it 'returns that framework' do
          expect(definition.framework_short_name).to eql(framework_short_name)
        end
      end

      context 'and it has full-stops in it' do
        let(:framework_short_name) { 'RM1043.5' }

        it 'returns that framework' do
          expect(definition.framework_short_name).to eql(framework_short_name)
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
    let(:definition_class) do
      Class.new(Framework::Definition::Base) do
        management_charge Framework::ManagementChargeCalculator::FlatRate.new(percentage: BigDecimal('5'))
      end
    end

    it 'acts as setter and getter for the calculator' do
      expect(definition_class.management_charge).to be_a(Framework::ManagementChargeCalculator::FlatRate)
      expect(definition_class.management_charge.percentage).to eq(BigDecimal('5'))
    end
  end

  describe 'Base.calculate_management_charge' do
    let(:definition_class) do
      Class.new(Framework::Definition::Base) do
        management_charge Framework::ManagementChargeCalculator::FlatRate.new(percentage: BigDecimal('1.5'))
      end
    end

    it 'returns the management charge calculation, rounded to 4 decimal places' do
      entry = double('entry', total_value: BigDecimal('102123.23'))

      expect(definition_class.calculate_management_charge(entry)).to eq BigDecimal('1531.8484')
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
