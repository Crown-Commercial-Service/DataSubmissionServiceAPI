class Task
  class AnticipatedUserNotifications
    include Enumerable

    attr_reader :month, :year

    def initialize(month:, year:)
      @month = month
      @year = year
    end

    def each
      return enum_for(:each) unless block_given?

      suppliers.find_each do |supplier|
        next if supplier.active_frameworks.empty?

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
                framework: framework_names_for(supplier)
              }
            }
          )
        end
      end
    end

    private

    def reporting_month
      @reporting_month ||= [Date::MONTHNAMES[month], year].join(' ')
    end

    def due_date
      @due_date ||= SubmissionWindow.new(year, month).due_date.to_fs(:day_month_year)
    end

    def suppliers
      @suppliers ||= Supplier.includes(:active_users, :active_frameworks).order(:name)
    end

    def framework_names_for(supplier)
      supplier.active_frameworks
              .map { |framework| "#{framework.short_name} - #{framework.name}" }
              .sort
    end
  end
end
