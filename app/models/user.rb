require './lib/auth0_api'

class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :suppliers, through: :memberships
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

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
    auth0_client = Auth0Api.new.client
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
    auth0_client = Auth0Api.new.client
    auth0_client.delete_user(auth_id)
    update auth_id: nil
  end

  def temporary_password
    "#{SecureRandom.urlsafe_base64}aA1!"
  end
end
