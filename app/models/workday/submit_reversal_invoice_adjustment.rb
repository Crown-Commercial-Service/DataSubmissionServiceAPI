module Workday
  # Used to generate an invoice adjustment that is a reversal of an original invoice
  # Reversal `total_spend` value is always the negated value of the original `total_spend`
  class SubmitReversalInvoiceAdjustment < SubmitInvoiceAdjustment
    private

    def line_item_description
      "Reversal of invoice for #{task_period_in_words} management charge"
    end

    def total_spend
      -super
    end
  end
end
