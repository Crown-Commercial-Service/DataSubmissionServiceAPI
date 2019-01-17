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
end
