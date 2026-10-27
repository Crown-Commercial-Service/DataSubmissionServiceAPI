class Task
  class UserNotificationRecipients
    include Enumerable

    def initialize(month:, year:, type: :anticipated)
      @month = month
      @year = year
      @type = type.to_sym

      unless %i[anticipated incomplete].include?(@type)
        raise ArgumentError, "Unknown notification type: #{@type}."
      end
    end

    def each
      return enum_for(:each) unless block_given?

      suppliers.find_each do |supplier|
        frameworks = frameworks_for(supplier)
        next if frameworks.empty?

        supplier.active_users.each do |user|
          yield (
            {
              email: user.email,
              supplier_name: supplier.name,
              personalisation: {
                due_date: due_date,
                person_name: user.name,
                supplier_name: supplier.name,
                reporting_month: reporting_month,
                framework: frameworks
              }
            }
          )
        end
      end
    end

    private

    attr_reader :month, :year, :type

    def reporting_month
      @reporting_month ||= [Date::MONTHNAMES[month], year].join(' ')
    end

    def due_date
      @due_date ||= Task::SubmissionWindow.new(year, month).due_date.to_fs(:day_month_year)
    end

    def suppliers
      if type == :anticipated
        Supplier.includes(:active_users, :active_frameworks)
      else
        Supplier.includes(:active_users, tasks: :framework)
                .joins(:tasks)
                .merge(incomplete_tasks)
                .distinct
      end
    end

    def incomplete_tasks
      Task.where(period_month: month, period_year: year).incomplete
    end

    def frameworks_for(supplier)
      frameworks = if type == :anticipated
                     supplier.active_frameworks
                   else
                    supplier.tasks.select do |task|
                      task.period_month == month && task.period_year == year && task.incomplete?
                    end.map(&:framework)
                   end

      frameworks.map { |framework| "#{framework.short_name} - #{framework.name}" }.uniq.sort
    end
  end
end
