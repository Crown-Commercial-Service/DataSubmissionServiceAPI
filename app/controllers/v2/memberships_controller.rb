class V2::MembershipsController < ActionController::API
  include ApiKeyAuthenticatable

  def index
    @memberships = Membership.all
    render json: @memberships
  end
end
