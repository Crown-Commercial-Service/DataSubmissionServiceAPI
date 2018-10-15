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
    framework.definition.for_entry_type(entry_type).total_value_field
  end

  def entry_type
    params[:entry_type] == 'invoice' ? 'invoice' : 'order'
  end
end
