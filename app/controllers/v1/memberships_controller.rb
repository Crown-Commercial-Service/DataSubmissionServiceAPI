class V1::MembershipsController < ApplicationController
  def index
    render jsonapi: Membership.all
  end
end
