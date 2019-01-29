class UpdateFrameworkRevenueCategoriesJob < ApplicationJob
  def perform
    response = HTTP.basic_auth(
      user: Workday.username,
      pass: Workday.api_password
    ).get(
      'https://wd3-impl-services1.workday.com/ccx/service/customreport2/' +
      Workday.tenant +
      '/INT003_ISU/CR_INT003_Commercial_Agreement_Cost_Center_and_Revenue_Category'
    )
    Nokogiri(response.to_s).xpath('//wd:Report_Entry').each do |framework_xml|
      framework_number = framework_xml.at_xpath('wd:Framework_Number').text
      revenue_category_wid_xml = framework_xml.at_xpath("wd:Revenue_Category_Level/wd:ID[@wd:type='WID']")
      revenue_category_wid = revenue_category_wid_xml.present? ? revenue_category_wid_xml.text : nil
      if (framework = Framework.find_by(short_name: framework_number))
        framework.update(revenue_category_wid: revenue_category_wid)
      end
    end
  end
end
