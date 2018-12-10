require 'rails_helper'

RSpec.describe Framework::EntryData do
  let(:entry_data_class) do
    Class.new(Framework::EntryData) do
      field 'Test Field', :string
    end
  end

  describe '.new_from_params' do
    it 'takes parameters and loads them into a new instance' do
      entry_data = entry_data_class.new_from_params(
        'Test Field' => 'test'
      )

      expect(entry_data.attributes).to include('Test Field' => 'test')
    end

    it 'ignores parameters that do not exist in the entry data definition' do
      entry_data = entry_data_class.new_from_params(
        'Test Field' => 'test',
        'Missing from Sheet' => true
      )

      expect(entry_data.attributes).not_to include('Missing from Sheet')
    end
  end
end
