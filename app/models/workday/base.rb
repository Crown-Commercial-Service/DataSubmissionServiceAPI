require 'lolsoap'
require 'akami'

module Workday
  CCS_COMPANY_REFERENCE = 'Crown_Commercial_Service'.freeze

  class Fault < StandardError; end

  class Base
    def set_wsse_header
      wsse = Akami.wsse
      wsse.credentials(Workday.api_username, Workday.api_password)
      request.header.__node__.parent << wsse.to_xml
    end
  end
end
