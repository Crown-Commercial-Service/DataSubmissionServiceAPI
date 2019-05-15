class Admin::UrnListsController < AdminController
  def index
    @urn_lists = UrnList.order(created_at: :desc).all
  end

  def new
    @urn_list = UrnList.new
  end

  def create
    @urn_list = UrnList.new(urn_list_params)

    return redirect_to admin_urn_lists_path if @urn_list.save

    render action: :new
  end

  private

  def urn_list_params
    params.require(:urn_list).permit(:excel_file)
  end
end
