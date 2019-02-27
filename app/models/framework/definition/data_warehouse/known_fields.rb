class Framework
  module Definition
    module DataWarehouse
      class KnownFields
        ALL = {
          'TotalValue' => :decimal,
          'CustomerPostCode' => :string,
          'CustomerName' => :string
        }.freeze

        def self.[](value)
          ALL.fetch(value)
        end
      end
    end
  end
end
