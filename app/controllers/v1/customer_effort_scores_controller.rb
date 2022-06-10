class V1::CustomerEffortScoresController < APIController
  deserializable_resource :customer_effort_score, only: %i[create]

  def create
    feedback = params.dig(:customer_effort_score)
    score = CustomerEffortScore.new(
      rating: feedback[:rating], 
      comments: feedback[:comments], 
      user_id: feedback[:user_id]
    )
    score.save!

    head :no_content
  end
end