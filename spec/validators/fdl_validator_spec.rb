require 'rails_helper'

RSpec.describe FdlValidator do
  let(:test_class) do
    Class.new do
      include ActiveModel::Attributes
      include ActiveModel::Validations
      extend ActiveModel::Naming

      def self.name
        'Framework'
      end

      attribute :fdl, :string
      validates :fdl, fdl: true
    end
  end

  subject(:instance) { test_class.new }

  before do
    instance.fdl = source
    instance.validate
  end

  context 'FDL is valid' do
    let(:source) do
      <<~FDL
        Framework RM6060 {
          Name 'Fake framework'
          ManagementCharge 0.5% of 'Supplier Price'
           InvoiceFields {
            InvoiceValue from 'Supplier Price'
          }
        }
      FDL
    end

    it { is_expected.to be_valid }
  end

  context 'FDL is invalid' do
    context 'syntactically' do
      let(:source) { 'Fxramework RM1234 {}' }

      it { is_expected.not_to be_valid }
      it 'has the ASCII tree of the failure' do
        expect(instance.errors[:fdl].first).to match(/Failed to match sequence/)
      end
    end
    context 'semantically' do
      let(:source) do
        <<~FDL
          Framework RMNOINVOICEVALUE {
            Name 'x'
            ManagementCharge 0%
             InvoiceFields {
              String from 'Supplier Price'
            }
          }
        FDL
      end

      it { is_expected.not_to be_valid }
      it 'has the first semantic failure' do
        expect(instance.errors[:fdl].first).to eql('InvoiceFields is missing an InvoiceValue field')
      end
    end
  end
end
