require 'rails_helper'
require 'stringio'

RSpec.describe Task::LateGenerator do
  subject(:generator) { Task::LateGenerator.new(year: year, month: month, output: output) }

  describe '#generate' do
    let(:output) { StringIO.new }

    context 'there are incomplete submissions for the month in question' do
      let(:year)  { 2019 }
      let(:month) { 1 }

      let(:alice)      { create :user, name: 'Alice Example', email: 'alice@example.com' }
      let(:bob)        { create :user, name: 'Bob Example', email: 'bob@example.com' }

      before do
        # Warning! Data creation yak ahead. In short:
        # Create two frameworks and two suppliers. Each supplier
        # has two incomplete tasks, and one of them has a completed
        # task. Each of the users with a membership in a supplier
        # needs to be told about the fact that something is wrong
        # with their submission for that framework
        # (the period is implied)
        framework1 = create :framework, short_name: 'RM0001'
        framework2 = create :framework, short_name: 'RM0002'

        framework3 = create :framework, short_name: 'COMPLETE0001'

        supplier_a = create :supplier
        supplier_b = create :supplier

        create :membership, user: alice, supplier: supplier_a
        create :membership, user: bob, supplier: supplier_b

        create :task, supplier: supplier_a, framework: framework1
        create :task, supplier: supplier_a, framework: framework2
        create :task, supplier: supplier_b, framework: framework1
        create :task, supplier: supplier_b, framework: framework2

        create :task, :completed, supplier: supplier_a, framework: framework3

        generator.generate
      end

      subject(:lines) { output.string.split("\n") }

      it 'has a header' do
        expect(lines.first).to eql('User Name,Email Address,Framework Number')
      end

      it 'has a line for each user in that supplier for each framework' do
        expect(lines).to include('Alice Example,alice@example.com,RM0001')
        expect(lines).to include('Alice Example,alice@example.com,RM0002')
        expect(lines).to include('Bob Example,bob@example.com,RM0001')
        expect(lines).to include('Bob Example,bob@example.com,RM0002')
      end

      it 'does not include completed tasks' do
        expect(lines).not_to include('Alice Example,alice@example.com,COMPLETE0001')
      end
    end
  end
end
