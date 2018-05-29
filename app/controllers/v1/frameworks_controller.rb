class V1::FrameworksController < ApplicationController
  def index
    @frameworks = Framework.all
  end

  def show
    @framework = Framework.find_by(id: params[:id])
  end
end
