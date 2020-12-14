module Export
  class FrameworkUsers
    module Extract
      def self.all_relevant(framework)
        User.select(
          <<~POSTGRESQL
            users.id                        AS id,
            '#{framework.short_name}'::text AS _framework_reference,
            '#{framework.name}'::text       AS _framework_name,
            suppliers.name                  AS _supplier_name,
            suppliers.salesforce_id         AS _supplier_salesforce_id,
            agreements.active               AS _supplier_active,
            users.name                      AS _user_name,
            users.email                     AS _user_email
          POSTGRESQL
        ).where(
          <<~POSTGRESQL 
          auth_id LIKE 'auth0|%' 
          POSTGRESQL
          ).joins(suppliers: :agreements).merge(Agreement.where(framework_id: framework.id))
      end
    end
  end
end
