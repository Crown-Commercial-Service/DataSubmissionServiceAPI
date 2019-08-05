require './lib/auth0_api'

class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :suppliers, through: :memberships
  has_many :submissions, through: :suppliers
  has_many :tasks, through: :suppliers
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :active, -> { where.not(auth_id: nil) }
  scope :inactive, -> { where(auth_id: nil) }

  def name=(value)
    super value.squish
  end

  def email=(value)
    super value.squish
  end

  def self.search(query)
    if query.present?
      eager_load(:suppliers)
        .where('users.name ILIKE :query OR email ILIKE :query OR suppliers.name ILIKE :query', query: "%#{query}%")
    else
      where(nil)
    end
  end

  def multiple_suppliers?
    suppliers.count > 1
  end

  def create_with_auth0
    return if active?
    return if user_already_exists_in_auth0?

    auth0_response = auth0_client.create_user(
      name,
      email: email,
      email_verified: true,
      password: temporary_password,
      connection: 'Username-Password-Authentication',
    )
    update auth_id: auth0_response.fetch('user_id')
  end

  def delete_on_auth0
    auth0_client.delete_user(auth_id)
    update auth_id: nil
  end

  def active?
    !auth_id.nil?
  end

  def deactivate
    return unless active?

    delete_on_auth0
  end

  def temporary_password
    "#{SecureRandom.urlsafe_base64}aA1!"
  end

  private

  def auth0_client
    @auth0_client ||= Auth0Api.new.client
  end

  def user_already_exists_in_auth0?
    auth0_response = auth0_client.get_users(q: "email:#{email}")
    auth0_client.headers = auth0_client.headers.except(:params)

    return false if auth0_response.empty?

    user_id = auth0_response[0]['user_id']
    update auth_id: user_id

    true
  end
end
