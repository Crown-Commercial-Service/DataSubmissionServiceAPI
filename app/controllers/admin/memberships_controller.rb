class Admin::MembershipsController < AdminController
  def show
    # redirect route in case of attempt to visit deprecated path
    redirect_to admin_root_path
  end
end
