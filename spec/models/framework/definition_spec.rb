require 'rails_helper'

RSpec.describe Framework::Definition do
  describe '.[]' do
    subject(:definition) { Framework::Definition[framework_short_name] }

    context 'the framework is RM6060, because we are trialling FDL with this framework' do
      let(:framework_short_name) { 'RM6060' }
      it 'is a functioning framework' do
        expect(definition.framework_short_name).to eql(framework_short_name)
      end

      it 'is an anonymous class' do
        expect(definition.to_s).to match(/Class:/)
      end

      it 'is cached so that we aren\'t repeatedly recompiling' do
        expect(definition).to eq(Framework::Definition[framework_short_name])
      end
    end

    context 'the framework is RM1070' do
      let(:framework_short_name) { 'RM1070' }

      it 'is an anonymous class' do
        expect(definition.to_s).to match(/Class:/)
      end

      it 'is cached so that we aren\'t repeatedly recompiling' do
        expect(definition).to eq(Framework::Definition[framework_short_name])
      end
    end

    context 'the framework exists' do
      context 'and it is fairly normal' do
        let(:framework_short_name) { 'RM3787' }
        it 'returns that framework' do
          expect(definition.framework_short_name).to eql(framework_short_name)
        end
      end

      context 'and it is loaded from the database' do
        let(:framework_short_name) { 'RM3821' }

        it 'returns that framework' do
          FactoryBot.create(:framework, :with_fdl, short_name: 'RM3821')

          expect(definition.framework_short_name).to eql 'RM3821'
          expect(definition.framework_name).to eql 'Data and Application Solutions'
          expect(definition.lots.size).to eql 14
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

        context 'and the framework is on the filesystem' do
          it 'returns that framework' do
            expect(definition.framework_short_name).to eql(framework_short_name)
          end
        end

        context 'and the framework is in the database' do
          let(:framework_short_name) { 'RM999.5' }

          before do
            create :framework, :with_fdl, short_name: 'RM999.5', fdl_file: 'RM999_5.fdl'
          end

          it 'returns that framework' do
            expect(definition.framework_short_name).to eql(framework_short_name)
          end
        end
      end
    end

    context 'the framework does not exist' do
      it 'raises a Framework::Definition::MissingError' do
        expect { Framework::Definition['RM1234'] }.to raise_error(
          Framework::Definition::MissingError, 'There is no framework definition for "RM1234"'
        )
      end
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
      expect(Framework::Definition['RM3756'].for_entry_type('invoice').model_name.name).to eq 'Invoice'
    end

    it 'returns the framework’s Contract definition for an ‘order’ entry_type' do
      expect(Framework::Definition['RM3756'].for_entry_type('order').model_name.name).to eq 'Contract'
    end
  end

  describe 'Base.attributes_for_entry_type' do
    it 'returns the attributes for the framework’s Invoice definition' do
      expected = [
        'Customer Invoice Date', 'Customer Invoice Number',\
        'Customer Organisation Name', 'Customer Post Code', 'Customer URN', 'Matter Name', 'Practitioner Grade',\
        'Price per Unit', 'Pricing Mechanism', 'Primary Specialism', 'Pro-Bono Price per Unit', 'Pro-Bono Quantity',\
        'Pro-Bono Total Value', 'Quantity', 'Service Type', 'Sub-Contractor Name (If Applicable)',\
        'Supplier Reference Number', 'Tier Number', 'Total Cost (ex VAT)', 'UNSPSC', 'Unit of Purchase',\
        'VAT Amount Charged'
      ]

      expect(Framework::Definition['RM3756'].attributes_for_entry_type('invoice')).to match_array(expected)
    end

    it 'returns the attributes for the framework’s Contract definition' do
      expected = [
        'Award Procedure', 'Call Off Managing Entity', 'Contract End Date', 'Contract Start Date',\
        'Customer Organisation Name', 'Customer Post Code', 'Customer Response Time', 'Customer URN',\
        'Expected Pro-Bono value', 'Expected Total Order Value', 'Expression Of Interest Used (Y/N)',\
        'Matter Description', 'Matter Name', 'Pro-bono work included? (Y/N)', 'Sub-Contractor Name',\
        'Supplier Reference Number', 'Tier Number'
      ]

      expect(Framework::Definition['RM3756'].attributes_for_entry_type('order')).to match_array(expected)
    end

    it 'returns an empty array, if the framework does not have Contracts' do
      expect(Framework::Definition['RM858'].attributes_for_entry_type('order')).to be_empty
    end
  end
end
