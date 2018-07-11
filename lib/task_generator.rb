class TaskGenerator
  def initialize(supplier:, framework:)
    @supplier = supplier
    @framework = framework
  end

  def create
    Task.create!(
      status: status,
      description: description,
      framework: @framework,
      supplier: @supplier,
      due_on: due_on,
      period_month: period_month,
      period_year: period_year
    )
  end

  private

  def description
    "MI for #{period_month} #{period_year} #{@framework.name} #{@framework.short_name}"
  end

  def status
    'unstarted'
  end

  def due_on
    '09/07/2018'
  end

  def period_month
    Date.parse(due_on).month
  end

  def period_year
    Date.parse(due_on).year
  end
end
