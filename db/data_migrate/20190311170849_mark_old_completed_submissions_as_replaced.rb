tasks_with_multiple_completed_submissions = Task.joins(:submissions)
                                                .where("submissions.aasm_state = 'completed'")
                                                .group('tasks.id')
                                                .having('count(submissions.id) > 1')

tasks_with_multiple_completed_submissions.each do |task|
  completed_submissions = task.submissions.where(aasm_state: 'completed').order(created_at: :desc)

  completed_submissions[1..-1].each(&:mark_as_replaced!)
end
