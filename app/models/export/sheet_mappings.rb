require 'framework/definition/base'

module Export
  ##
  # Included on SubmissionEntryRow to let us map per-template fields
  module SheetMappings
    def source_field_for(dest_field_name, framework_short_name)
      sheet_definition = sheet_definition(framework_short_name, model.entry_type)
      sheet_definition.export_mappings[dest_field_name]
    end

    private

    def sheet_definition(framework_short_name, entry_type)
      require_dependency "framework/definition/#{framework_short_name}"
      "Framework::Definition::#{framework_short_name}::#{entry_type.titleize}".constantize
    rescue LoadError
      raise Framework::Definition::MissingError, %(Please run rails g framework:definition "#{framework_short_name}")
    end
  end
end
