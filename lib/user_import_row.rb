class UserImportRow
  REQUIRED_KEYS = %i[email personname suppliername].freeze

  def initialize(row, auth0_client)
    @row = row
    @auth0_client = auth0_client

    check_for_required_keys!
  end

  def import!
    name = @row[:personname]
    email = @row[:email].strip
    supplier = @row[:suppliername]
    password = SecureRandom.alphanumeric(20)

    begin
      new_user = @auth0_client.create_user(
        name,
        connection: 'Username-Password-Authentication',
        email: email,
        password: password,
        verify_email: false,
        user_metadata: {
          supplier: supplier
        }
      )
    rescue Auth0::Unsupported => e
      # Ignore error when user already exists
      raise unless JSON.parse(e.message)['statusCode'] == 409
    end

    Rails.logger.info "#{new_user['user_id']},#{email},#{password},#{name}" if new_user
  end

  private

  def check_for_required_keys!
    raise MissingKey unless (REQUIRED_KEYS - @row.keys).empty?
  end

  class MissingKey < StandardError; end
end
