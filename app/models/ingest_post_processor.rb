class IngestPostProcessor
  attr_reader :params, :framework

  def initialize(params:, framework:)
    @params = params
    @framework = framework
  end

  def resolve_parameters
    params[:total_value] = total_value_from_data_hash
    params
  end

  private

  def total_value_from_data_hash
    params.dig(:data, total_value_field)
  end

  def total_value_field
    "#{framework.definition}::#{entry_type.capitalize}".constantize.total_value_field
  end

  def entry_type
    params[:entry_type] == 'invoice' ? 'invoice' : 'order'
  end
end
