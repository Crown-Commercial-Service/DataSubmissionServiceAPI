class V1::CustomerEffortScoresController < APIController
  deserializable_resource :customer_effort_score, only: %i[create]

  def create
    feedback = params[:customer_effort_score]
    score = CustomerEffortScore.new(
      rating: rating_to_integer(feedback[:rating]),
      comments: feedback[:comments],
      user_id: feedback[:user_id]
    )
    score.save!

    head :no_content
  end

  private

  def rating_to_integer(feedback)
    case feedback
    when 'Very easy' then 5
    when 'Easy' then 4
    when 'Neither easy or hard' then 3
    when 'Hard' then 2
    when 'Very hard' then 1
    end
  end
end
