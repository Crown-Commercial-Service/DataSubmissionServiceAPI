require 'rails_helper'

RSpec.describe Framework::ManagementChargeCalculator::ColumnBased do
  it 'calculates the management charge for an entry, based on the value of a given column' do
    entry = FactoryBot.create(:submission_entry, total_value: 123.45, data: { test_value: 'test' })

    calculator = Framework::ManagementChargeCalculator::ColumnBased.new(
      varies_by: 'test_value',
      value_to_percentage: {
        'other': { percentage: 0 },
        'test': { percentage: BigDecimal('10') }
      }
    )

    expect(calculator.calculate_for(entry)).to eq(12.345) # 10% of 123.45
  end

  it 'handles column values that have a different case to the rule' do
    entry = FactoryBot.create(:submission_entry, total_value: 123.45, data: { test_value: 'TeST' })

    calculator = Framework::ManagementChargeCalculator::ColumnBased.new(
      varies_by: 'test_value',
      value_to_percentage: {
        'Test': { percentage: BigDecimal('5') }
      }
    )

    expect(calculator.calculate_for(entry)).to eq(6.1725) # 5% of 123.45
  end

  it 'handles column values that are integers' do
    entry = FactoryBot.create(:submission_entry, total_value: 123.45, data: { test_value: 1 })

    calculator = Framework::ManagementChargeCalculator::ColumnBased.new(
      varies_by: 'test_value',
      value_to_percentage: {
        '1': { percentage: BigDecimal('5') }
      }
    )

    expect(calculator.calculate_for(entry)).to eq(6.1725) # 5% of 123.45
  end

  it 'rounds to four decimal places' do
    entry = FactoryBot.create(:submission_entry, total_value: 42.424242, data: { test_value: 'test' })

    calculator = Framework::ManagementChargeCalculator::ColumnBased.new(
      varies_by: 'test_value',
      value_to_percentage: {
        'test': { percentage: BigDecimal('0.5') }
      }
    )

    expect(calculator.calculate_for(entry)).to eq(0.2121) # 0.5% of 123.45
  end

  it 'correctly calculates charges when FDL gives integer percentages' do
    entry = FactoryBot.create(:submission_entry, total_value: 42.424242, data: { test_value: 'test' })

    calculator = Framework::ManagementChargeCalculator::ColumnBased.new(
      varies_by: 'test_value',
      value_to_percentage: {
        'test': { percentage: 1 }
      }
    )

    expect(calculator.calculate_for(entry)).to eq(0.4242) # 1% of 42.424242
  end

  it 'when the lookup fails, which should have been caught by validation, assume zero rate' do
    entry = FactoryBot.create(:submission_entry, total_value: 42.424242, data: { test_value: 'invalid' })

    calculator = Framework::ManagementChargeCalculator::ColumnBased.new(
      varies_by: 'test_value',
      value_to_percentage: {
        'test': { percentage: BigDecimal('0.5') }
      }
    )

    expect(Rollbar).to receive(:error)
    expect(calculator.calculate_for(entry)).to eq(0)
  end

  context 'varies by two columns' do
    it 'calculates the management charge for an entry, based on the given columns' do
      entry = FactoryBot.create(:submission_entry,
                                total_value: 2400.0,
                                data: {
                                  'Lot Number': '2',
                                  'Spend Code': 'Other Re-charges'
                                })

      calculator = Framework::ManagementChargeCalculator::ColumnBased.new(
        varies_by: ['Lot Number', 'Spend Code'],
        value_to_percentage: {
          ['1', 'Other Re-charges'] => { percentage: BigDecimal('0.5') },
          ['2', 'Other Re-charges'] => { percentage: BigDecimal('1.5') }
        }
      )

      expect(calculator.calculate_for(entry)).to eql(36) # 1.5% of 2,400.00
    end

    context 'percentage is calculated from other columns for particular lot numbers' do
      let(:calculator) do
        Framework::ManagementChargeCalculator::ColumnBased.new(
          varies_by: ['Lot Number'],
          value_to_percentage: {
            ['2'] => { percentage: BigDecimal('1.5'), column: 'Other Price' },
            ['3'] => { percentage: BigDecimal('0.5'), column: ['Other Price', 'Another Price'] }
          }
        )
      end

      it 'calculates the management charge for an entry, based on another column' do
        entry = FactoryBot.create(:submission_entry,
                                  total_value: 2400.0,
                                  data: {
                                    'Lot Number': '2',
                                    'Other Price': 100.00
                                  })

        expect(calculator.calculate_for(entry)).to eql(1.5) # 1.5% of 100.00
      end

      it 'calculates the management charge for an entry, based on the sum of other columns' do
        entry = FactoryBot.create(:submission_entry,
                                  total_value: 2400.0,
                                  data: {
                                    'Lot Number': '3',
                                    'Other Price': 100.00,
                                    'Another Price': 200.00
                                  })

        expect(calculator.calculate_for(entry)).to eql(1.5) # 0.5% of (100.00 + 200.00)
      end
    end

    context 'dictionary includes wildcards' do
      let(:calculator) do
        Framework::ManagementChargeCalculator::ColumnBased.new(
          varies_by: ['Lot Number', 'Spend Code'],
          value_to_percentage: {
            [Framework::Definition::AST::Any, Framework::Definition::AST::Any] => { percentage: BigDecimal('2.0') },
            ['1', Framework::Definition::AST::Any] => { percentage: BigDecimal('1.5') },
            ['1', 'Damages'] => { percentage: BigDecimal('0.5') }
          }
        )
      end

      it 'exactly matches all columns, if that combination is valid' do
        entry = FactoryBot.create(:submission_entry,
                                  total_value: 2400.0,
                                  data: {
                                    'Lot Number': '1',
                                    'Spend Code': 'Damages'
                                  })

        expect(calculator.calculate_for(entry)).to eql(12) # 0.5% of 2,400.00
      end

      it 'matches on all but the last column, if an exact match was not found' do
        entry = FactoryBot.create(:submission_entry,
                                  total_value: 2400.0,
                                  data: {
                                    'Lot Number': '1',
                                    'Spend Code': 'Other Re-charges'
                                  })

        expect(calculator.calculate_for(entry)).to eql(36) # 1.5% of 2,400.00
      end

      it 'finally tries the default value, where all columns are wildcards' do
        entry = FactoryBot.create(:submission_entry,
                                  total_value: 2400.0,
                                  data: {
                                    'Lot Number': '3', # There is no lot 3
                                    'Spend Code': 'Other Re-charges'
                                  })

        expect(calculator.calculate_for(entry)).to eql(48) # 2% of 2,400.00
      end

      context 'when no fallback wildcard lookup defined' do
        let(:calculator) do
          Framework::ManagementChargeCalculator::ColumnBased.new(
            varies_by: ['Lot Number', 'Spend Code'],
            value_to_percentage: {
              ['1', Framework::Definition::AST::Any] => { percentage: BigDecimal('1.5') }
            }
          )
        end

        it 'assume zero rate, and report the missing validation lookup to Rollbar' do
          entry = FactoryBot.create(:submission_entry,
                                    total_value: 2400.0,
                                    data: {
                                      'Lot Number': '3', # There is no lot 3
                                      'Spend Code': 'Other Re-charges'
                                    })

          expect(Rollbar).to receive(:error)
          expect(calculator.calculate_for(entry)).to eq(0)
        end
      end
    end
  end

  context 'varies by three columns' do
    it 'calculates the management charge for an entry, based on the given columns' do
      entry = FactoryBot.create(:submission_entry,
                                total_value: 2400.0,
                                data: {
                                  'Lot Number': '2',
                                  'Spend Code': 'Other Re-charges',
                                  'Secondary Spend Code': 'Additional'
                                })

      calculator = Framework::ManagementChargeCalculator::ColumnBased.new(
        varies_by: ['Lot Number', 'Spend Code', 'Secondary Spend Code'],
        value_to_percentage: {
          ['1', 'Other Re-charges', 'Additional'] => { percentage: BigDecimal('0.5') },
          ['2', 'Other Re-charges', 'Normal'] => { percentage: BigDecimal('1.5') },
          ['2', 'Other Re-charges', 'Additional'] => { percentage: BigDecimal('1.0') },
        }
      )

      expect(calculator.calculate_for(entry)).to eql(24) # 1% of 2,400.00
    end
  end
end
