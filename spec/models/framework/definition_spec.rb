require 'rails_helper'

RSpec.describe Framework::Definition do
  describe '.[]' do
    subject(:definition) { Framework::Definition[framework_short_name] }

    context 'the framework exists' do
      context 'and it is fairly normal' do
        let(:framework_short_name) { 'RM3787' }
        it 'returns that framework' do
          expect(definition.framework_short_name).to eql(framework_short_name)
        end
      end

      context 'and it has slashes in it' do
        let(:framework_short_name) { 'CM/OSG/05/3565' }
        it 'returns that framework' do
          expect(definition.framework_short_name).to eql(framework_short_name)
        end
      end
    end

    context 'the framework does not exist' do
      it 'raises a Framework::Definition::MissingError' do
        expect { Framework::Definition['RM1234'] }.to raise_error(
          Framework::Definition::MissingError, 'Please run rails g framework:definition "RM1234"'
        )
      end
    end
  end

  describe '.all' do
    it 'gets everything that is descended from Framework::Definition::Base and nothing else' do
      expect(Framework::Definition.all.length).to be > 0
      expect(Framework::Definition.all).to all(satisfy { |c| c.ancestors.include?(Framework::Definition::Base) })
    end
  end
end
