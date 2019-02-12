module OmniAuth
  module Strategies
    # The DeveloperAdmin strategy is for use in development only.
    # It allows us to load the admin interface without the need
    # to talk to an external auth provider.
    #
    # You need to set ADMIN_EMAILS to a list with a single email
    # address in it. When you go to log in it will show a form
    # with that email address and a default developer name. You
    # should just be able to click Sign In at that stage.
    #
    # It's set up from config/initializers/omniauth but also
    # requires a POST route in config/routes.rb
    #
    #   use OmniAuth::Builder do
    #     provider :developer_admin
    #   end
    class DeveloperAdmin
      include OmniAuth::Strategy

      DEFAULT_EMAIL = 'delia.veloper@dxw.com'.freeze

      option :name, 'developer_admin'
      option :email, ENV['ADMIN_EMAILS'] || DEFAULT_EMAIL
      option :users_name, 'Delia Veloper'

      uid { 'email' }

      def request_phase
        form = OmniAuth::Form.new(
          title: 'Default developer admin credentials', url: callback_path
        )
        form.html "\n<input type='text' id='email' name='email' value='#{options[:email]}'/>"
        form.html "\n<input type='text' id='name' name='name' value='#{options[:users_name]}'/>"
        form.button 'Sign In'
        form.to_response
      end

      info do
        {
          name: request.params['name'],
          email: request.params['email']
        }
      end

      ##
      # This strategy only applies when the Google credentials are missing
      # and we're in development
      def self.applies?
        Rails.env.development? &&
          (ENV['GOOGLE_CLIENT_ID'].blank? || ENV['GOOGLE_CLIENT_SECRET'].blank?)
      end
    end
  end
end
