require 'rails_helper'
require 'framework/definition/parser'

RSpec.describe Framework::Definition::Parser do
  subject(:parser) { Framework::Definition::Parser.new }
  let(:framework_definition) { 'Framework CM/OSG/05/3565 {}' }

  describe '#framework_definition' do
    it { is_expected.to parse(framework_definition) }
  end

  describe '#framework_identifier' do
    subject { parser.framework_identifier }

    it { is_expected.to parse('CM/OSG/05/3565').as(string: 'CM/OSG/05/3565') }
    it { is_expected.to parse('RM3710').as(string: 'RM3710') }
    it { is_expected.not_to parse('foobar') }
  end
end
