require 'rails_helper'

RSpec.describe Framework::Sheet do
  let(:sheet_class) do
    Class.new(Framework::Sheet) do
      field 'Test Field', :string
    end
  end

  describe '.new_from_params' do
    it 'takes parameters and loads them into a new instance' do
      sheet = sheet_class.new_from_params(
        'Test Field' => 'test'
      )

      expect(sheet.attributes).to include('Test Field' => 'test')
    end

    it 'ignores parameters that do not exist in the sheet definition' do
      sheet = sheet_class.new_from_params(
        'Test Field' => 'test',
        'Missing from Sheet' => true
      )

      expect(sheet.attributes).not_to include('Missing from Sheet')
    end
  end
end
