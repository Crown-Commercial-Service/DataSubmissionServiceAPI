require 'rails_helper'

RSpec.describe Framework::Definition::Language do
  describe '.generate_framework_definition' do
    subject(:definition) { Framework::Definition::Language.generate_framework_definition(source) }

    context 'we have some valid FDL' do
      let(:source) { 'Framework CM/05/3769 {}' }

      it 'is a Framework::Definition::Base' do
        expect(definition.ancestors).to include(Framework::Definition::Base)
      end
    end
  end
end
