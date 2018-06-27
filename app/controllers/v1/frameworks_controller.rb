class V1::FrameworksController < ApplicationController
  def index
    render jsonapi: Framework.all
  end

  def show
    render jsonapi: Framework.find(params[:id])
  end
end
