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
        @existing_user ||= User.find_by('lower(email) = ?', email.downcase)
      end

      def create_user!
        user = User.new(email: email, name: name)
        CreateUser.new(user: user).call
        user
      end
    end
  end
end
