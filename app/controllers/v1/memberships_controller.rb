class V1::MembershipsController < ApplicationController
  def index
    memberships = Membership.where(nil)
    memberships = memberships.where(supplier_id: params.dig(:filter, :supplier_id)) if params.dig(:filter, :supplier_id)
    memberships = memberships.where(user_id: params.dig(:filter, :user_id)) if params.dig(:filter, :user_id)

    render jsonapi: memberships
  end
end
