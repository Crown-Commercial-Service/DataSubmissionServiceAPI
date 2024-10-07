require Rails.root.join('lib', 'simple_form', 'optional_labels')

SimpleForm::Components::Labels.prepend SimpleForm::Components::OptionalLabels
SimpleForm::Components::Labels::ClassMethods.include SimpleForm::Components::OptionalLabels::ClassMethods

SimpleForm.setup do |config|
  config.wrappers :default, tag: 'div',
                            class: 'govuk-form-group', error_class: 'govuk-form-group--error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'govuk-label'
    b.use :full_error, wrap_with: { tag: 'span', class: 'govuk-error-message' }
    b.use :hint, wrap_with: { tag: 'span', class: 'govuk-hint' }
    b.use :input, class: 'govuk-input', error_class: 'govuk-input--error'
  end

  config.wrappers :govuk_textarea_wrapper, parent: :default do |b|
    b.use :label, class: 'govuk-label'
    b.use :full_error, wrap_with: { tag: 'span', class: 'govuk-error-message' }
    b.use :input, class: 'govuk-textarea', input_html: { rows: 5 }
  end

  # The default wrapper to be used by the FormBuilder.
  config.default_wrapper = :default

  # Define the way to render check boxes / radio buttons with labels.
  # Defaults to :nested for bootstrap config.
  #   inline: input + label
  #   nested: label > input
  config.boolean_style = :inline

  # Default class for buttons
  config.button_class = 'govuk-button'

  # Method used to tidy up errors. Specify any Rails Array method.
  # :first lists the first message for each field.
  # Use :to_sentence to list all errors for each field.
  config.error_method = :first

  # Default tag used for error notification helper.
  config.error_notification_tag = :div

  # CSS class to add for error notification helper.
  config.error_notification_class = 'error_notification'

  # Whether attributes are required by default (or not). Default is true.
  config.required_by_default = false

  # Tell browsers whether to use the native HTML5 validations (novalidate form option).
  # These validations are enabled in SimpleForm's internal config but disabled by default
  # in this configuration, which is recommended due to some quirks from different browsers.
  # To stop SimpleForm from generating the novalidate option, enabling the HTML5 validations,
  # change this configuration to true.
  config.browser_validations = false

  # Define the default class of the input wrapper of the boolean input.
  config.boolean_label_class = 'checkbox'

  # Append 'optional' label instead of prepending
  config.label_text = ->(label, optional, _explicit_label) { "#{label}<span class=\"govuk-hint\">#{optional}</span>" }
end
