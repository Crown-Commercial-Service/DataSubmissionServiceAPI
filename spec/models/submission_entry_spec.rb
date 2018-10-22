require 'rails_helper'

RSpec.describe SubmissionEntry do
  it { is_expected.to belong_to(:submission) }
  it { is_expected.to belong_to(:submission_file) }

  it { is_expected.to validate_presence_of(:data) }

  describe 'sheet scope' do
    let(:sheet_1_entry) { FactoryBot.create(:submission_entry, sheet_name: 'Sheet 1') }
    let(:another_sheet_1_entry) { FactoryBot.create(:submission_entry, sheet_name: 'Sheet 1') }
    let(:sheet_2_entry) { FactoryBot.create(:submission_entry, sheet_name: 'Sheet 2') }

    it 'returns entries for the specified sheet' do
      expect(SubmissionEntry.sheet('Sheet 1')).to contain_exactly(sheet_1_entry, another_sheet_1_entry)
      expect(SubmissionEntry.sheet('Sheet 2')).to contain_exactly(sheet_2_entry)
    end
  end

  describe 'sector scopes' do
    let(:home_office) { FactoryBot.create(:customer, :central_government, name: 'Home Office') }
    let(:health_dept) { FactoryBot.create(:customer, :central_government, name: 'Department for Health') }
    let(:bobs_charity) { FactoryBot.create(:customer, :wider_public_sector, name: 'Bob’s Charity') }

    let!(:home_office_entry) { FactoryBot.create(:submission_entry, customer_urn: home_office.urn) }
    let!(:health_dept_entry) { FactoryBot.create(:submission_entry, customer_urn: health_dept.urn) }
    let!(:bobs_charity_entry) { FactoryBot.create(:submission_entry, customer_urn: bobs_charity.urn) }

    it 'return entries for the specified sectors' do
      expect(SubmissionEntry.central_government).to contain_exactly(home_office_entry, health_dept_entry)
      expect(SubmissionEntry.wider_public_sector).to contain_exactly(bobs_charity_entry)
    end
  end

  describe 'ordered_by_row' do
    let!(:tenth_row) { FactoryBot.create(:submission_entry, row: 10) }
    let!(:first_row)  { FactoryBot.create(:submission_entry, row: 1) }
    let!(:second_row) { FactoryBot.create(:submission_entry, row: 2) }

    it 'returns entries ordered by their source row' do
      expect(SubmissionEntry.ordered_by_row).to eq [first_row, second_row, tenth_row]
    end
  end

  it 'is associated with a customer via the customer‘s URN' do
    customer = FactoryBot.create(:customer)
    submission_entry = FactoryBot.create(:submission_entry, customer_urn: customer.urn)

    expect(submission_entry.customer).to eq customer
  end
end
