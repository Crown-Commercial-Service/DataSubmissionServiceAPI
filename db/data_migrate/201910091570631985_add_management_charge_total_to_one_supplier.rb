# Zendesk ticket: https://dxw.zendesk.com/agent/tickets/10151
#
# Execute with:
#
#   rails runner db/data_migrate/201910091570631985_add_management_charge_total_to_one_supplier.rb
#

puts 'Backfilling management_charge_total for CORPORATE TRAVEL MANAGEMENT (NORTH) LIMITED'

supplier = Supplier.find_by(name: 'CORPORATE TRAVEL MANAGEMENT (NORTH) LIMITED')
raise 'Supplier not found!' unless supplier

Submission.transaction do
  supplier.submissions.each do |submission|
    next unless submission.management_charge_total.nil?

    submission.management_charge_total = submission.entries.invoices.sum(:management_charge)
    submission.save!
  end
end
