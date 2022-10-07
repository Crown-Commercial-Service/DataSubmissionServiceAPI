class V1::AgreementsController < APIController
  def index
    agreements = current_user.agreements
    agreements = agreements.includes(requested_associations)
    agreements = agreements.where(active: params.dig(:filter, :active)) if params.dig(:filter, :active)

    render jsonapi: agreements, include: params[:include]
  end

  private

  def requested_associations
    params.fetch(:include, '').split(',').map(&:to_sym)
  end
end
