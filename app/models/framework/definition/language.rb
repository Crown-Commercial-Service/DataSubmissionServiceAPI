class Framework
  module Definition
    class Language
      class << self
        def [](framework_short_name)
          fdl_source = Framework.find_by(short_name: framework_short_name)&.definition_source

          raise ArgumentError, "Cannot find source for #{framework_short_name}" \
            if fdl_source.blank?

          generator = Generator.new(fdl_source)
          generator.definition
        end
      end
    end
  end
end
