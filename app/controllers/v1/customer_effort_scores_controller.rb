class V1::CustomerEffortScoresController < APIController
  deserializable_resource :customer_effort_score, only: %i[create]

  def create
    pp "params::::::::::::"
    pp params
    pp "customer_effort_score_params:::::::"
    pp customer_effort_score_params
    score = CustomerEffortScore.new(
      rating: customer_effort_score_params[:ratings], 
      comments: customer_effort_score_params[:comments], 
      user_id: customer_effort_score_params[:user_id]
    )
    score.save!
  end

  private

  def customer_effort_score_params
    params.require(:customer_effort_score).permit(:ratings, :comments, :user_id)
  end
end