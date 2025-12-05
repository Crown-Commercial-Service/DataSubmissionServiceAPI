module Workday
  # This is called for a submission that has a positive management_charge, was invoiced for,
  # and needs to be reversed, therefore generating an invoice adjustment to reverse the orginal invoice
  # Increase_Amount_Due is set to false, which means the Extended_Amount is credit,
  # meaning that negative management_charge needs to be made positive
  # Reversal `total_spend` value is always the negated value of the original `total_spend`
  class SubmitReversalInvoiceAdjustment < SubmitInvoiceAdjustment
    def initialize(submission, user = nil)
      @user = user
      super(submission)
    end

    private

    attr_reader :user

    def line_item_description
      # rubocop:disable Layout/LineLength
      "Reversal of invoice #{submission.invoice_details[:invoice_number]} adjustment for #{task_period_in_words} management charge"
      # rubocop:enable Layout/LineLength
    end

    def total_spend
      -super
    end

    def submitted_by_note_content
      "#{user&.name} : #{user&.email}"
    end
  end
end
