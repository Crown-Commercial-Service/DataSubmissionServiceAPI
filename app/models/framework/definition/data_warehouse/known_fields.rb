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
          'UnitQuantity' => :decimal,
          'InvoiceNumber' => :string,
          'UNSPSC' => :integer,
          'VATCharged' => :decimal,
          'LotNumber' => :lot_number,
          'PromotionCode' => :string
        }.freeze

        def self.type_for(value)
          ALL.fetch(value)
        end
      end
    end
  end
end
