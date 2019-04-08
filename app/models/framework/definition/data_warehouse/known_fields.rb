class Framework
  module Definition
    module DataWarehouse
      class KnownFields
        class NotFoundError < KeyError; end

        ALL = {
          'InvoiceValue' => :decimal,
          'ContractValue' => :decimal,
          'CustomerPostCode' => :string,
          'CustomerPostcode' => :string,
          'CustomerName' => :string,
          'CustomerURN' => :urn,
          'InvoiceDate' => :date,
          'ProductGroup' => :string,
          'ProductClass' => :string,
          'ProductSubClass' => :string,
          'ProductDescription' => :string,
          'ProductCode' => :string,
          'UnitCost' => :decimal,
          'UnitPrice' => :decimal,
          'UnitType' => :string,
          'VATIncluded' => :yesno,
          'UnitQuantity' => :decimal,
          'InvoiceNumber' => :string,
          'UNSPSC' => :integer,
          'VATCharged' => :decimal,
          'LotNumber' => :lot_number,
          'PromotionCode' => :string,
          'CustomerInvoiceDate' => :date,
          'CustOrderDate' => :date,
          'SupplierReferenceNumber' => :string,
          'CustomerReferenceNumber' => :string,
          'ContractStartDate' => :date,
          'ContractEndDate' => :date,
          'ContractAwardChannel' => :string,
          'Expenses' => :decimal
        }.freeze

        def self.type_for(value)
          ALL.fetch(value)
        rescue KeyError => e
          raise NotFoundError, "known field with key not found: '#{e.key}'"
        end
      end
    end
  end
end
