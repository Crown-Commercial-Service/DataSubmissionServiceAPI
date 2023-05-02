class V1::CustomerEffortScoresController < ApiController
  deserializable_resource :customer_effort_score, only: %i[create]

  def create
    feedback = params[:customer_effort_score]
    customer_effort_score = CustomerEffortScore.new(
      rating: rating_to_integer(feedback[:rating]),
      comments: feedback[:comments],
      user_id: feedback[:user_id]
    )

    if customer_effort_score.save
      head :no_content
    else
      render jsonapi_errors: customer_effort_score.errors, status: :bad_request
    end
  end

  private

  def rating_to_integer(feedback)
    case feedback
    when 'Very easy' then 5
    when 'Easy' then 4
    when 'Neither easy or difficult' then 3
    when 'Difficult' then 2
    when 'Very difficult' then 1
    end
  end
end
