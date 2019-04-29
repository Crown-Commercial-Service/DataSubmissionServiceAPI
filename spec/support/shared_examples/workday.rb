RSpec.shared_examples 'a workday request' do
  describe '#url' do
    it 'returns the URL for the Workday Revenue Management web service' do
      expect(request.url).to eq 'https://wd3-impl-services1.workday.com/ccx/service/crowncommercialservice/Revenue_Management/v31.0'
    end
  end
end
RSpec.shared_examples 'an authenticated workday request' do
  describe 'Security header' do
    let(:wsse_namespace) do
      { 'xmlns:wsse' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd' }
    end

    around(:example) do |example|
      old_username = Workday.api_username
      old_password = Workday.api_password
      Workday.api_username = 'a_username'
      Workday.api_password = 'some_password'

      example.run

      Workday.api_username = old_username
      Workday.api_password = old_password
    end

    it 'sets a wsse:UsernameToken security header for authenticating against the API' do
      header = Nokogiri::XML(request.content).at_xpath('//soap:Envelope//soap:Header')

      expect(
        header.at_xpath('//wsse:Security//wsse:UsernameToken//wsse:Username', wsse_namespace).text
      ).to eq 'a_username'

      expect(
        header.at_xpath('//wsse:Security//wsse:UsernameToken//wsse:Password', wsse_namespace).text
      ).to eq 'some_password'
    end
  end
end
