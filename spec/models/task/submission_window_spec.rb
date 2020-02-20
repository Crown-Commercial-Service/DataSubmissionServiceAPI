require 'rails_helper'

RSpec.describe Task::SubmissionWindow do
  let(:submission_window) { Task::SubmissionWindow.new(year, month) }
  let(:month) { 12 }
  let(:year) { 2018 }

  before { stub_govuk_bank_holidays_request }

  describe '#due_date' do
    subject(:due_date) { submission_window.due_date }

    it 'adjusts the due date when there are bank holidays so there are always at least 5 working days' do
      expect(due_date).to eq Date.new(2019, 1, 8)
    end
  end
end
