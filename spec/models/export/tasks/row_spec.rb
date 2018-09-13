require 'rails_helper'

RSpec.describe Export::Tasks::Row do
  describe '#year_and_month' do
    it 'left-pads single digit months' do
      row = Export::Tasks::Row.new(FactoryBot.build(:task, period_year: 2018, period_month: 8))
      expect(row.year_and_month).to eql('201808')
    end
  end
end
