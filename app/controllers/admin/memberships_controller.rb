class Admin::MembershipsController < AdminController
  def show
    # redirect route in case of attempt to visit deprecated path
    return redirect_to admin_root_path
  end
end
