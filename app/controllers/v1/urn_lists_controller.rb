class V1::UrnListsController < APIController
  skip_before_action :reject_without_user!

  def index
    urn_list = UrnList.processed.order(created_at: :desc).first

    render jsonapi: urn_list, status: :ok
  end
end
