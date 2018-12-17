module Import
  class Users
    class Row
      attr_reader :email, :name, :supplier

      def initialize(email:, name:, supplier_salesforce_id:)
        @email = email
        @name = name
        @supplier = Supplier.find_by!(salesforce_id: supplier_salesforce_id)
      end

      def import!
        user = existing_user.presence || create_user!
        user.suppliers << supplier unless user.suppliers.include?(supplier)
        user
      end

      private

      def existing_user
        @existing_user ||= User.find_by(email: email)
      end

      def create_user!
        user = User.create!(email: email, name: name)
        user.create_with_auth0
        user
      end
    end
  end
end
