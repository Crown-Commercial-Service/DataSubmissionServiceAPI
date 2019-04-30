class Framework
  module Definition
    class Language
      class << self
        def [](framework_short_name)
          sanitized_short_name = framework_short_name.tr('/.', '_')

          fdl_filename = Rails.root.join("app/models/framework/definition/#{sanitized_short_name}.fdl")

          fdl_source = if File.exist?(fdl_filename)
                         File.read(fdl_filename)
                       else
                         Framework.find_by(short_name: framework_short_name)&.definition_source
                       end

          raise ArgumentError, "Cannot find source for #{framework_short_name} in filesystem or database" \
            if fdl_source.blank?

          generator = ::Framework::Definition::Generator.new(fdl_source)
          generator.definition
        end
      end
    end
  end
end
