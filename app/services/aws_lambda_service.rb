class AWSLambdaService
  def initialize(submission_id:)
    @payload = { submission_id: submission_id }
  end

  def client
    @client ||= Aws::Lambda::Client.new(
      region: ENV['AWS_S3_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
  end

  def trigger
    # This operation invokes a Lambda function
    resp = client.invoke(
      function_name: ENV['AWS_LAMBDA_CALCULATE'],
      invocation_type: 'Event', # asynchronously OR can be changed to 'RequestResponse' to wait for the response
      payload: @payload.to_json,
      log_type: 'Tail',
    )

    resp.to_h
  end
end
