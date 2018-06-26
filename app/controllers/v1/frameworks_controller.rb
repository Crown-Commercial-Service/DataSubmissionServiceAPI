class V1::FrameworksController < ApplicationController
  def index
    render jsonapi: Framework.all
  end

  def show
    @framework = Framework.find_by(id: params[:id])
  end
end
