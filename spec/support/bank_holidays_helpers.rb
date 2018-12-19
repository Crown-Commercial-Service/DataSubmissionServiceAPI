module BankHolidaysHelpers
  def stub_govuk_bank_holidays_request
    stub_request(:get, 'https://www.gov.uk/bank-holidays.json')
      .to_return(status: 200, body: bank_holidays_json)
  end

  def bank_holidays_json
    File.read(Rails.root.join('spec', 'fixtures', 'bank_holidays.json'))
  end
end
