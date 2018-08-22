Submission
  .where(aasm_state: :in_review)
  .select { |s| s.entries.errored.any? }
  .update_all!(aasm_state: :validation_failed)
