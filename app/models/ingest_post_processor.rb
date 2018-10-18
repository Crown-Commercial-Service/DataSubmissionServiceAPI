class IngestPostProcessor
  attr_reader :params, :framework

  def initialize(params:, framework:)
    @params = params
    @framework = framework
  end

  def resolve_parameters
    params[:total_value] = total_value
    params[:customer_urn] = customer_urn
    params
  end

  def customer_urn
    urn = params.dig(:data, framework_definition.export_mappings['CustomerURN'])
    urn if Customer.exists?(urn: urn)
  end

  def total_value
    params.dig(:data, framework_definition.total_value_field)
  end

  private

  def framework_definition
    @framework_definition ||= framework.definition.for_entry_type(entry_type)
  end

  def entry_type
    params[:entry_type] == 'invoice' ? 'invoice' : 'order'
  end
end
