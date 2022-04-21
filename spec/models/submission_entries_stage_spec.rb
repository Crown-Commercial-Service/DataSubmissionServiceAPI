require 'rails_helper'

RSpec.describe SubmissionEntriesStage do
  it { is_expected.to belong_to(:submission) }
  it { is_expected.to belong_to(:submission_file) }

  it { is_expected.to validate_presence_of(:data) }

  describe 'sheet scope' do
    let(:sheet_1_entry) { FactoryBot.create(:submission_entries sheet_name: 'Sheet 1') }
    let(:another_sheet_1_entry) { FactoryBot.create(:submission_entries, sheet_name: 'Sheet 1') }
    let(:sheet_2_entry) { FactoryBot.create(:submission_entries, sheet_name: 'Sheet 2') }

    it 'returns entries for the specified sheet' do
      expect(SubmissionEntriesStage.sheet('Sheet 1')).to contain_exactly(sheet_1_entry, another_sheet_1_entry)
      expect(SubmissionEntriesStage.sheet('Sheet 2')).to contain_exactly(sheet_2_entry)
    end
  end

  describe 'sector scopes' do
    let(:home_office) { FactoryBot.create(:customer, :central_government, name: 'Home Office') }
    let(:health_dept) { FactoryBot.create(:customer, :central_government, name: 'Department for Health') }
    let(:bobs_charity) { FactoryBot.create(:customer, :wider_public_sector, name: 'Bob’s Charity') }

    let!(:home_office_entry) { FactoryBot.create(:submission_entries, customer_urn: home_office.urn) }
    let!(:health_dept_entry) { FactoryBot.create(:submission_entries, customer_urn: health_dept.urn) }
    let!(:bobs_charity_entry) { FactoryBot.create(:submission_entries, customer_urn: bobs_charity.urn) }

    it 'return entries for the specified sectors' do
      expect(SubmissionEntriesStage.central_government).to contain_exactly(home_office_entry, health_dept_entry)
      expect(SubmissionEntriesStage.wider_public_sector).to contain_exactly(bobs_charity_entry)
    end
  end

  describe 'ordered_by_row' do
    let!(:tenth_row) { FactoryBot.create(:submission_entries_stages, row: 10) }
    let!(:first_row)  { FactoryBot.create(:submission_entries_stages, row: 1) }
    let!(:second_row) { FactoryBot.create(:submission_entries_stages, row: 2) }

    it 'returns entries ordered by their source row' do
      expect(SubmissionEntriesStage.ordered_by_row).to eq [first_row, second_row, tenth_row]
    end
  end

  it 'is associated with a customer via the customer‘s URN' do
    customer = FactoryBot.create(:customer)
    submission_entries_stages = FactoryBot.create(:submission_entries_stages, customer_urn: customer.urn)

    expect(submission_entries_stages.customer).to eq customer
  end

  describe 'validate_against!' do
    let!(:customer) { FactoryBot.create(:customer, urn: 12345678) }
    let(:supplier) { submission.supplier }
    let(:framework) { FactoryBot.create(:framework, :with_fdl, lot_count: 2, short_name: 'RM3767') }
    let(:sheet_definition) { framework.definition.for_entry_type(entry.entry_type) }
    let(:submission) { FactoryBot.create(:submission, framework: framework) }
    let(:entry) { FactoryBot.create(:invoice_entry, submission: submission, data: data_hash) }
    let(:agreement) { FactoryBot.create(:agreement, framework: framework, supplier: supplier) }
    let(:valid_lot_number) { agreement.lot_numbers.first }
    let!(:agreement_framework_lot) do
      FactoryBot.create(:agreement_framework_lot, agreement: agreement, framework_lot: framework.lots.first)
    end
    let(:valid_data_hash) do
      {
        'Lot Number' => valid_lot_number,
        'Customer URN' => '12345678',
        'Customer Organisation Name' => 'Organisation Name',
        'Customer Invoice Date' => '01/01/2018',
        'Customer Invoice Number' => 1234,
        'Tyre Brand' => 'BMW',
        'Tyre Width' => '123',
        'Aspect Ratio' => '1x2',
        'Rim Diameter' => '123',
        'Load Capacity' => '123',
        'Speed Index' => '123',
        'Vehicle Category' => 'Car',
        'Tyre Grade' => 'Premium',
        'Product Type' => 'Tyre - Supply ONLY',
        'Associated Service' => 'Something',
        'Price per Unit' => 12.00,
        'Quantity' => 10,
        'VAT Amount Charged' => 4,
        'UNSPSC' => '1234',
        'Total Cost (ex VAT)' => 12.34,
        'Run Flats (Y/N)' => 'N'
      }
    end

    before { entry.validate_against!(sheet_definition) }

    context 'with a valid data hash' do
      let(:data_hash) { valid_data_hash }

      it 'transitions state to validated' do
        expect(entry).to be_validated
        expect(entry.validation_errors).to eq({})
      end
    end

    context 'with an invalid data hash' do
      let(:data_hash) { valid_data_hash.merge('UNSPSC' => nil) }

      it 'transitions state to errored' do
        expect(entry).to be_errored
      end

      it 'sets the validation errors' do
        expect(entry.validation_errors).to eq(
          [
            {
              'message' => 'is not a number',
              'location' => {
                'row' => entry.source['row'],
                'column' => 'UNSPSC',
              },
            }
          ]
        )
      end
    end

    context 'with a blank required string' do
      let(:data_hash) { valid_data_hash.merge('Associated Service' => '') }

      it 'transitions state to errored' do
        expect(entry).to be_errored
      end

      it 'sets the validation errors' do
        expect(entry.validation_errors).to eq(
          [
            {
              'message' => 'can\'t be blank',
              'location' => {
                'row' => entry.source['row'],
                'column' => 'Associated Service',
              },
            }
          ]
        )
      end
    end

    context 'with a lot number the supplier does not have an agreement against' do
      let(:data_hash) { valid_data_hash.merge('Lot Number' => 'XXX') }

      it 'transitions state to errored' do
        expect(entry).to be_errored
      end

      it 'sets the validation errors' do
        expect(entry.validation_errors).to eq(
          [
            {
              'message' => 'is not included in the supplier framework agreement',
              'location' => {
                'row' => entry.source['row'],
                'column' => 'Lot Number',
              },
            }
          ]
        )
      end
    end
  end
end
