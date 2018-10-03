require 'rails_helper'

RSpec.describe Export::Template do
  describe '.source_field_for' do
    # rubocop:disable Style/StructInheritance
    class TemplateUserRow < Struct.new(:model)
      include Export::Template
    end
    # rubocop:enable Style/StructInheritance

    let(:model)            { double 'SubmissionEntryRow', entry_type: entry_type }
    let(:submission_entry) { TemplateUserRow.new(model) }

    subject { submission_entry.source_field_for(dest_field_name, framework_short_name) }

    context 'the framework does not exist' do
      let(:entry_type) { 'invoice' }
      it 'tells us with a KeyError' do
        expect do
          submission_entry.source_field_for('some_field', 'NON-EXISTENT FRAMEWORK')
        end.to raise_error(KeyError)
      end
    end

    context 'a valid framework is given' do
      let(:framework_short_name) { 'RM3756' }

      context 'the entry_type is invoice' do
        let(:entry_type)      { 'invoice' }
        let(:dest_field_name) { 'UnitPrice' }

        it { is_expected.to eql('Price per Unit') }
      end

      context 'the entry_type is order' do
        let(:entry_type)      { 'order' }
        let(:dest_field_name) { 'ContractValue' }

        it { is_expected.to eql('Expected Total Order Value') }
      end
    end
  end
end
