class SerializableInactiveCustomer < JSONAPI::Serializable::Resource
  type 'inactive_customers'

  attributes :inactive_urn, :inactive_customer_name, :date_made_inactive, :replacement_urn, :replacement_customer_name,
             :replacement_post_code, :replacement_status
end
