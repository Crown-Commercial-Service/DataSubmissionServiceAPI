supplier = Supplier.find_or_create_by!(name: 'Bobs Cheese Shop')
due_date = Date.today.next_month.change(day: 7)


framework_unstarted = Framework.find_or_create_by!(short_name: 'cboard8', name: 'Cheese Board 8')
Agreement.find_or_create_by!(supplier: supplier, framework: framework_unstarted)
Task.find_or_create_by!(
  status: :unstarted,
  due_on: due_date,
  framework: framework_unstarted,
  supplier: supplier,
  period_month: Date.today.month,
  period_year: Date.today.year,
  description: 'Unstarted task'
)


framework_pending = Framework.find_or_create_by!(short_name: 'cboard9', name: 'Cheese Board 9')
Agreement.find_or_create_by!(supplier: supplier, framework: framework_pending)
in_progress_task = Task.find_or_create_by!(
  status: :in_progress,
  due_on: due_date,
  framework: framework_pending,
  supplier: supplier,
  period_month: Date.today.month,
  period_year: Date.today.year,
  description: 'In progress task (pending submission)'
)
supplier.submissions.find_or_create_by!(framework: framework_pending, task: in_progress_task)


framework_processing = Framework.find_or_create_by!(short_name: 'cboard10', name: 'Cheese Board 10')
Agreement.find_or_create_by!(supplier: supplier, framework: framework_processing)
task_processing = Task.find_or_create_by!(
  status: :in_progress,
  due_on: due_date,
  framework: framework_processing,
  supplier: supplier,
  period_month: Date.today.month,
  period_year: Date.today.year,
  description: 'In progress task (processing submission)'
)
processing_submission = supplier.submissions.find_or_create_by!(framework: framework_processing, task: task_processing, aasm_state: "processing")
submission_file = processing_submission.files.find_or_create_by!(rows: 2)
submission_file.file.attach(
  io: File.open("spec/fixtures/not-really-an.xls"),
  filename: 'not-really-an.xls'
)
processing_submission.entries.find_or_create_by!(submission_file: submission_file, data: { key: "value" }, entry_type: 'invoice', source: { sheet: "InvoicesRaised", row: 1 })
processing_submission.entries.find_or_create_by!(submission_file: submission_file, data: { key: "another value" }, entry_type: 'invoice', source: { sheet: "InvoicesRaised", row: 2 })


framework_valid = Framework.find_or_create_by!(short_name: 'cboard11', name: 'Cheese Board 11')
Agreement.find_or_create_by!(supplier: supplier, framework: framework_valid)
task_in_review = Task.find_or_create_by!(
  status: :in_progress,
  due_on: due_date,
  framework: framework_valid,
  supplier: supplier,
  period_month: Date.today.month,
  period_year: Date.today.year,
  description: 'In review task (validated submission)'
)
valid_submission = supplier.submissions.find_or_create_by!(framework: framework_valid, task: task_in_review, aasm_state: "in_review", management_charge: 3000)
submission_file = valid_submission.files.find_or_create_by!(rows: 2)
submission_file.file.attach(
  io: File.open("spec/fixtures/not-really-an.xls"),
  filename: 'not-really-an.xls'
)
valid_submission.entries.find_or_create_by!(submission_file: submission_file, aasm_state: "validated", data: { key: "value" }, entry_type: 'invoice', source: { sheet: "InvoicesRaised", row: 1 })
valid_submission.entries.find_or_create_by!(submission_file: submission_file, aasm_state: "validated", data: { key: "another value" }, entry_type: 'invoice', source: { sheet: "InvoicesRaised", row: 2 })
valid_submission.entries.find_or_create_by!(submission_file: submission_file, aasm_state: "validated", data: { key: "value" }, entry_type: 'order', source: { sheet: "OrdersReceived", row: 1 })
valid_submission.entries.find_or_create_by!(submission_file: submission_file, aasm_state: "validated", data: { key: "another value" }, entry_type: 'order', source: { sheet: "OrdersReceived", row: 2 })


framework_invalid = Framework.find_or_create_by!(short_name: 'cboard12', name: 'Cheese Board 12')
Agreement.find_or_create_by!(supplier: supplier, framework: framework_invalid)
task_in_review_with_errors = Task.find_or_create_by!(
  status: :in_progress,
  due_on: due_date,
  framework: framework_invalid,
  supplier: supplier,
  period_month: Date.today.month,
  period_year: Date.today.year,
  description: 'Validation failed task (invalid submission)'
)
invalid_submission = supplier.submissions.find_or_create_by!(framework: framework_invalid, task: task_in_review_with_errors, aasm_state: "validation_failed")
submission_file = invalid_submission.files.find_or_create_by!(rows: 2)
submission_file.file.attach(
  io: File.open("spec/fixtures/not-really-an.xls"),
  filename: 'not-really-an.xls'
)
invalid_submission.entries.find_or_create_by!(submission_file: submission_file, aasm_state: "validated", data: { key: "value" }, entry_type: 'invoice', source: { sheet: "InvoicesRaised", row: 1 })
invalid_submission.entries.find_or_create_by!(
  submission_file: submission_file,
  aasm_state: "errored",
  data: { key: "" },
  entry_type: 'invoice', source: { sheet: "InvoicesRaised", row: 2 },
).update_attribute(:validation_errors, [{ "message": "Required value error", "location": { "row": 2, "column": 1 } }])

# completed task
framework_completed = Framework.find_or_create_by!(short_name: 'cboard13', name: 'Cheese Board 13')
Agreement.find_or_create_by!(supplier: supplier, framework: framework_completed)
task_completed = Task.find_or_create_by!(
  status: :completed,
  due_on: due_date,
  framework: framework_completed,
  supplier: supplier,
  period_month: Date.today.month,
  period_year: Date.today.year,
  description: 'Completed task'
)
valid_submission = supplier.submissions.find_or_create_by!(framework: framework_completed, task: task_completed, aasm_state: "completed")
submission_file = valid_submission.files.find_or_create_by!(rows: 2)
submission_file.file.attach(
  io: File.open("spec/fixtures/not-really-an.xls"),
  filename: 'not-really-an.xls'
)
valid_submission.entries.find_or_create_by!(submission_file: submission_file, aasm_state: "validated", data: { key: "value" }, entry_type: 'invoice', source: { sheet: "InvoicesRaised", row: 1 })
valid_submission.entries.find_or_create_by!(submission_file: submission_file, aasm_state: "validated", data: { key: "another value" }, entry_type: 'invoice', source: { sheet: "InvoicesRaised", row: 2 })
