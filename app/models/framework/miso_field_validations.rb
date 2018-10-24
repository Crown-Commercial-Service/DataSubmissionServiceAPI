class Framework
  class MisoFieldValidations
    attr_reader :fields, :validations

    def initialize(fields)
      @fields = fields
      @validations = {}
    end

    def rules
      fields.each { |field| validations[field['DisplayName']] = [] }

      generate_mandatory_field_rules
      generate_boolean_field_rules
      generate_decimal_field_rules
      generate_integer_field_rules
      generate_date_field_rules
      generate_urn_field_rule

      validations.reject { |_k, v| v.empty? }
    end

    private

    def generate_mandatory_field_rules
      fields
        .select { |field| field['Mandatory'] == 'True' }
        .each do |field|
          validations[field['DisplayName']] << 'presence: true'
        end
    end

    def generate_boolean_field_rules
      fields
        .select { |field| field['SystemDataType'] == 'System.Boolean' }
        .each do |field|
          validations[field['DisplayName']] << 'inclusion: { in: %w[true false] }'
        end
    end

    def generate_date_field_rules
      fields
        .select { |field| field['SystemDataType'] == 'System.Date' }
        .each do |field|
          validations[field['DisplayName']] << 'ingested_date: true'
        end
    end

    def generate_decimal_field_rules
      fields
        .select { |field| field['SystemDataType'] == 'System.Decimal' }
        .each do |field|
          validations[field['DisplayName']] << 'numericality: true'
        end
    end

    def generate_integer_field_rules
      fields
        .select { |field| field['SystemDataType'] == 'System.Int32' }
        .each do |field|
          validations[field['DisplayName']] << 'numericality: { only_integer: true }'
        end
    end

    def generate_urn_field_rule
      urn_field = fields.find { |f| f['ExportsTo'] == 'CustomerURN' }
      return if urn_field.nil?

      validations[urn_field['DisplayName']] << 'urn: true'
    end
  end
end
