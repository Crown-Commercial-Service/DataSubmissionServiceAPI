class Framework
  module Definition
    module DataWarehouse
      class KnownFields
        ALL = {
          'InvoiceValue' => :decimal,
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
          'UnitType' => :string,
          'VATIncluded' => :yesno,
          'UnitQuantity' => :decimal
        }.freeze

        def self.type_for(value)
          ALL.fetch(value)
        end
      end
    end
  end
end
