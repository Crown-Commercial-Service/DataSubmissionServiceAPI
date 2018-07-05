class V1::MembershipsController < ApplicationController
  deserializable_resource :membership, only: [:create]

  def index
    memberships = Membership.where(nil)
    memberships = memberships.where(supplier_id: params.dig(:filter, :supplier_id)) if params.dig(:filter, :supplier_id)
    memberships = memberships.where(user_id: params.dig(:filter, :user_id)) if params.dig(:filter, :user_id)

    render jsonapi: memberships
  end

  def create
    membership = Membership.new(create_membership_params)

    if membership.save
      render jsonapi: membership, status: :created
    else
      render jsonapi_errors: membership.errors, status: :bad_request
    end
  end

  private

  def create_membership_params
    params.require(:membership).permit(:user_id, :supplier_id)
  end
end
