class Framework
  module Definition
    module DataWarehouse
      class KnownFields
        ALL = {
          'TotalValue' => :decimal,
          'CustomerPostCode' => :string,
          'CustomerName' => :string,
          'CustomerURN' => :urn,
          'InvoiceDate' => :date,
          'ProductGroup' => :string,
          'ProductClass' => :string,
          'ProductSubClass' => :string,
          'ProductDescription' => :string,
          'ProductCode' => :string,
          'UnitPrice' => :decimal,
          'UnitType' => :string
        }.freeze

        def self.[](value)
          ALL.fetch(value)
        end
      end
    end
  end
end
