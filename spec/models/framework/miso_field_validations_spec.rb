require 'rails_helper'

RSpec.describe Framework::MisoFieldValidations do
  let(:framework_short_name) { 'RM1070' }
  let(:invoice_fields) { Framework::MisoFields.new(framework_short_name).invoice_fields }
  let(:validation) { Framework::MisoFieldValidations.new(invoice_fields) }

  describe '#rules' do
    describe 'presence validation' do
      it 'is included for mandatory fields' do
        expect(validation.rules['Lot Number']).to include('presence: true')
      end

      it 'is not included for mandatory decimal fields' do
        expect(validation.rules['Invoice Price Per Vehicle']).not_to include('presence: true')
      end

      it 'is not included for mandatory integer fields' do
        expect(validation.rules['UNSPSC']).not_to include('presence: true')
      end

      it 'is not included for mandatory date fields' do
        expect(validation.rules['Customer Invoice Date']).not_to include('presence: true')
      end

      it 'is not included on mandatory URN validations' do
        expect(validation.rules['Customer URN']).not_to include('presence: true')
      end
    end
  end

  it 'returns numericality validations for decimal and integer fields' do
    expect(validation.rules['Invoice Price Per Vehicle']).to include('numericality: true')
    expect(validation.rules['UNSPSC']).to include('numericality: { only_integer: true }')
  end

  it 'returns date validations for date fields' do
    expect(validation.rules['Customer Invoice Date']).to include('ingested_date: true')
  end

  it 'returns inclusion validations for boolean fields' do
    expect(validation.rules['VAT Applicable?']).to include('inclusion: { in: %w[true false] }')
  end

  it 'returns URN validations' do
    expect(validation.rules['Customer URN']).to include('urn: true')
  end
end
