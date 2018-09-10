submission_ids = Submission
                 .where(aasm_state: :in_review)
                 .select { |s| s.entries.errored.any? }
                 .pluck(:id)

# rubocop:disable Rails/SkipsModelValidations
# Using `update_all` specifically, so not to touch
# `updated_at` value

Submission
  .where(id: submission_ids)
  .update_all(aasm_state: :validation_failed)

# rubocop:enable Rails/SkipsModelValidations
