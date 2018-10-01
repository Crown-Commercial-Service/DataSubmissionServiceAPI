require 'rails_helper'

RSpec.describe Export::Template do
  class TemplateUserRow
    include Export::Template
  end

  let(:submission_entry) { TemplateUserRow.new }

  describe '.source_field_for' do
    subject { submission_entry.source_field_for(dest_field_name, framework_short_name) }

    context 'the framework does not exist' do
      it 'tells us with a KeyError' do
        expect do
          submission_entry.source_field_for('some_field', 'NON-EXISTENT FRAMEWORK')
        end.to raise_error(KeyError)
      end
    end

    context 'a valid framework is given' do
      let(:framework_short_name) { 'RM3756' }

      context 'a valid field name for the framework is given' do
        let(:dest_field_name) { 'CustomerURN' }
        it { is_expected.to eql('Customer URN') }
      end
    end

    context 'an entry_type is given' do
      let(:entry_type) { 'contract' }
      let(:dest_field_name) { 'ProductThing' }

      it 'gets the value specific to the contract variant' do

      end
    end
  end
end
