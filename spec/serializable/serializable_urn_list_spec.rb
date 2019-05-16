require 'rails_helper'

RSpec.describe SerializableUrnList do
  context 'given a URN list' do
    let(:urn_list) { create(:urn_list, aasm_state: :processed, filename: 'customers.xlsx') }
    let(:serialized_urn_list) { SerializableUrnList.new(object: urn_list) }

    it "exposes the attached file's name" do
      expect(serialized_urn_list.as_jsonapi[:attributes][:filename]).to eql 'customers.xlsx'
      expect(serialized_urn_list.as_jsonapi[:attributes][:byte_size]).to eql 9142
      expect(serialized_urn_list.as_jsonapi[:attributes][:file_key]).to eql urn_list.file_key
    end
  end
end
