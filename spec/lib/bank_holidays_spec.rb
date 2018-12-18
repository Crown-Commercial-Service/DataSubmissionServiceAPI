require 'rails_helper'
require 'bank_holidays'

RSpec.describe BankHolidays do
  before { stub_govuk_bank_holidays_request }

  describe '.all' do
    it 'returns an array of the dates for upcoming bank holidays in England and Wales' do
      bank_holidays = [
        Date.parse('2018-04-02'),
        Date.parse('2018-05-07'),
        Date.parse('2018-05-28'),
        Date.parse('2018-08-27'),
        Date.parse('2018-12-25'),
        Date.parse('2018-12-26'),
        Date.parse('2019-01-01'),
        Date.parse('2019-04-19'),
        Date.parse('2019-04-22'),
        Date.parse('2019-05-06'),
        Date.parse('2019-05-27'),
        Date.parse('2019-08-26'),
        Date.parse('2019-12-25'),
        Date.parse('2019-12-26')
      ]

      expect(BankHolidays.all).to eq bank_holidays
    end
  end

  describe '.future' do
    it 'returns an array of the dates for upcoming bank holidays in England and Wales' do
      travel_to Date.new(2018, 12, 12) do
        future_bank_holidays = [
          Date.parse('2018-12-25'),
          Date.parse('2018-12-26'),
          Date.parse('2019-01-01'),
          Date.parse('2019-04-19'),
          Date.parse('2019-04-22'),
          Date.parse('2019-05-06'),
          Date.parse('2019-05-27'),
          Date.parse('2019-08-26'),
          Date.parse('2019-12-25'),
          Date.parse('2019-12-26')
        ]

        expect(BankHolidays.future).to eq future_bank_holidays
      end
    end
  end

  private

  def stub_govuk_bank_holidays_request
    stub_request(:get, 'https://www.gov.uk/bank-holidays.json')
      .to_return(status: 200, body: bank_holidays_json)
  end

  def bank_holidays_json
    File.read(Rails.root.join('spec', 'fixtures', 'bank_holidays.json'))
  end
end
