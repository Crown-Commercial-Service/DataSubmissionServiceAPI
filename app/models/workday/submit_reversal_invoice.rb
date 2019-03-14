module Workday
  # This is called for a submission that has a negative management_charge, was invoiced for,
  # and needs to be reversed, therefore generating an invoice to reverse the orginal invoice adjustment
  # Reversal `total_spend` value is always the negated value of the original `total_spend`
  class SubmitReversalInvoice < SubmitInvoice
    private

    def line_item_description
      "Reversal of invoice adjustment for #{task_period_in_words} management charge"
    end

    def total_spend
      -super
    end
  end
end
