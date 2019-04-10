module AdminHelper
  def support_email_address
    'report-mi@crowncommercial.gov.uk'
  end

  def link_to_suppliers(suppliers)
    supplier_links = suppliers.collect do |supplier|
      link_to supplier.name, admin_supplier_path(supplier)
    end
    to_sentence(supplier_links)
  end

  def flash_types_css_class(type)
    {
      success: 'ccs-in-service-alert--success',
      failure: 'ccs-in-service-alert--failure',
      fdl_failure: 'ccs-in-service-alert--fdl-failure',
      notice: 'ccs-in-service-alert--notice',
      warning: 'ccs-in-service-alert--warning',
      alert: 'ccs-in-service-alert--failure'
    }[type.to_sym]
  end

  def flash_header_for(key)
    'Definition error' if key.to_s == 'fdl_failure'
  end
end
