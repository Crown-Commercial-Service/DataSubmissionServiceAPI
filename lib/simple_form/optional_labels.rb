module SimpleForm
  module Components
    module OptionalLabels
      module ClassMethods
        def translate_optional_html
          I18n.t(
            :"simple_form.optional.html",
            default: translate_optional_text
          )
        end

        def translate_optional_text
          I18n.t(:"simple_form.optional.text", default: 'This value is optional')
        end
      end

      protected

      def required_label_text #:nodoc:
        return if required_field? || options[:hide_optional]

        self.class.translate_optional_html.dup
      end
    end
  end
end
