class Framework
  module Definition
    class Language
      class << self
        def [](framework_short_name)
          sanitized_short_name = framework_short_name.tr('/.', '_')

          fdl_filename = Rails.root.join("app/models/framework/definition/#{sanitized_short_name}.fdl")

          raise ArgumentError, "#{framework_short_name}.fdl does not exist in models/framework/definition" \
            unless File.exist?(fdl_filename)

          generator = Generator.new(File.read(fdl_filename))
          generator.definition
        end
      end
    end
  end
end
