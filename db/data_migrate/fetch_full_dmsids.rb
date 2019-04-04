require 'roo'
require 'roo-xls'

submission_ids = SubmissionEntry
                 .where("LENGTH(data->>'Digital Marketplace Service ID') = 4")
                 .where(aasm_state: 'validated')
                 .pluck(:submission_id)
                 .uniq

# submission_ids = Array(submission_ids.first) # for testing

submission_ids.each do |submission_id|
  submission = Submission.find(submission_id)
  file = submission.files&.first
  next if file.nil?

  invoice_entries = submission.entries.invoices.order("CAST(source->>'row' AS INTEGER)")
  order_entries = submission.entries.orders.order("CAST(source->>'row' AS INTEGER)")

  url = file.temporary_download_url
  tmpfile = "/tmp/#{submission_id}.xls"

  puts "Fetching submission ##{submission_id}"
  `curl -s -o "#{tmpfile}" "#{url}"`

  extension = file.filename.split('.').last.downcase
  puts "Parsing uploaded #{extension.upcase} spreadsheet"
  spreadsheet = Roo::Spreadsheet.open(tmpfile, extension: extension)

  puts "Spreadsheet has sheets: #{spreadsheet.sheets.to_sentence}"

  invoices_sheet = spreadsheet.sheet('InvoicesRaised')
  dmsid_column = invoices_sheet.row(1).index('Digital Marketplace Service ID')

  invoices_sheet.each_with_index do |row, idx|
    next if idx.zero? # Skip header row - ruby iterator zero-indexed

    invoice_entry = invoice_entries.find_by("CAST(source->>'row' AS INTEGER) = ?", idx + 1) # Excel rows are 1-indexed
    next if invoice_entry.nil?
    next if invoice_entry.data['Digital Marketplace Service ID'].nil?

    corrected_dmsid = row[dmsid_column].to_s.delete(' ')
    puts "Invoice Row ##{idx + 1} Entry ##{invoice_entry.id} - #{invoice_entry.data['Digital Marketplace Service ID']} => #{corrected_dmsid}"
  end

  orders_sheet = if spreadsheet.sheets.include?('Contracts')
                   spreadsheet.sheet('Contracts')
                 elsif spreadsheet.sheets.include?('OrdersReceived')
                   spreadsheet.sheet('OrdersReceived')
                 else
                   spreadsheet.sheet('New Call Off Contracts')
                 end
  dmsid_column = orders_sheet.row(1).index('Digital Marketplace Service ID')

  orders_sheet.each_with_index do |row, idx|
    next if idx.zero? # Skip header row - ruby iterator zero-indexed

    order_entry = order_entries.find_by("CAST(source->>'row' AS INTEGER) = ?", idx + 1) # Excel rows are 1-indexed
    next if order_entry.nil?
    next if order_entry.data['Digital Marketplace Service ID'].nil?

    corrected_dmsid = row[dmsid_column].to_s.delete(' ')
    puts "Order   Row ##{idx + 1} Entry ##{order_entry.id} - #{order_entry.data['Digital Marketplace Service ID']} => #{corrected_dmsid}"
  end

  File.delete(tmpfile)
end
