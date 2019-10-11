# Zendesk ticket: https://dxw.zendesk.com/agent/tickets/10151
#
# Execute with:
#
#   rails runner db/data_migrate/201910091570631985_add_management_charge_total_to_one_supplier.rb
#

puts 'Backfilling management_charge_total for CORPORATE TRAVEL MANAGEMENT (NORTH) LIMITED and Lex Autolease'

['Lex Autolease', 'CORPORATE TRAVEL MANAGEMENT (NORTH) LIMITED'].each do |supplier_name|
  supplier = Supplier.find_by(name: supplier_name)
  raise 'Supplier not found!' unless supplier

  Submission.transaction do
    supplier.submissions.each do |submission|
      next unless submission.management_charge_total.nil?

      submission.management_charge_total = submission.entries.invoices.sum(:management_charge)
      submission.save!
    end
  end
end
