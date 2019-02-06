class Workday::CommercialAgreements
  def revenue_category_ids
    result = {}
    report_entries.each do |report_entry|
      framework_number = report_entry.at_xpath('wd:Framework_Number').text
      revenue_category_wid_xml = report_entry.at_xpath('wd:Revenue_Category_ID/wd:ID[@wd:type="clRevenueCategory"]')
      result[framework_number] = revenue_category_wid_xml.text if revenue_category_wid_xml
    end
    result
  end

  def tax_code_ids
    result = {}
    report_entries.each do |report_entry|
      framework_number = report_entry.at_xpath('wd:Framework_Number').text
      tax_code_xml = report_entry.at_xpath('wd:Tax_Code_Reference/wd:ID[@wd:type="commercialAgreementTaxCode"]')
      result[framework_number] = tax_code_xml.text if tax_code_xml
    end
    result
  end

  private

  def report_entries
    @report_entries ||= Nokogiri(commercial_agreement_xml).xpath('//wd:Report_Entry')
  end

  def commercial_agreement_xml
    @commercial_agreement_xml ||= HTTP.basic_auth(
      user: Workday.username,
      pass: Workday.api_password
    ).get(
      'https://wd3-impl-services1.workday.com/ccx/service/customreport2/' +
      Workday.tenant +
      '/INT003_ISU/CR_INT003_Commercial_Agreement_Cost_Center_and_Revenue_Category'
    ).to_s
  end
end
