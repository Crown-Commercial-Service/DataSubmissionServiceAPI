class BankHolidays
  GOV_UK_BANK_HOLIDAYS_URL = 'https://www.gov.uk/bank-holidays.json'.freeze

  # Returns the upcoming bank holidays for England and Wales as published
  # on GOV.UK
  def self.future
    all.reject { |date| date < Date.current }
  end

  # Returns all the bank holidays (past and future) for England and Wales as
  # published on GOV.UK
  def self.all
    Rails.cache.fetch 'bank_holiday_dates', expires_in: 12.hours do
      bank_holidays_json['england-and-wales']['events'].map { |event| Date.parse(event['date']) }
    end
  end

  def self.bank_holidays_json
    url = URI(GOV_UK_BANK_HOLIDAYS_URL)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request['content-type'] = 'application/json'

    response = http.request(request)
    JSON.parse(response.read_body)
  end
end
