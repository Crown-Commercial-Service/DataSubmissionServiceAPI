require 'rails_helper'

RSpec.describe Task::SubmissionWindow do
  let(:submission_window) { Task::SubmissionWindow.new(year, month) }
  let(:year) { 2018 }

  before { stub_govuk_bank_holidays_request }

  describe '#due_date' do
    subject(:due_date) { submission_window.due_date }

    context 'starting on a Monday' do
      let(:month) { 9 }

      it 'sets the due date to the 5th' do
        is_expected.to eq Date.new(2018, 10, 5)
      end
    end

    context 'skipping weekends' do
      let(:month) { 7 }

      it 'sets the due date to the 7th, taking into account the weekend' do
        is_expected.to eq Date.new(2018, 8, 7)
      end
    end

    context 'skipping bank holidays' do
      let(:month) { 12 }

      it 'sets the due date the 8th, taking into account New Year’s Day and the weekend' do
        is_expected.to eq Date.new(2019, 1, 8)
      end
    end
  end
end
