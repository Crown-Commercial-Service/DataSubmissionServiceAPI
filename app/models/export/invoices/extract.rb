module Export
  class Invoices
    module Extract
      def self.all_relevant
        Invoice.all
      end
    end
  end
end
