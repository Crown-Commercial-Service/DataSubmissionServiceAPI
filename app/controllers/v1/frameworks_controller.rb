class V1::FrameworksController < ApplicationController
  def index
    @frameworks = Framework.all
  end
end
