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

      ##
      # This strategy only applies when the Google credentials are missing
      # and we're in development
      def self.applies?
        Rails.env.development? &&
          (ENV['GOOGLE_CLIENT_ID'].blank? || ENV['GOOGLE_CLIENT_SECRET'].blank?)
      end

      def self.admin_email
        ENV['ADMIN_EMAILS'].presence&.split(',')&.first || 'Please set ADMIN_EMAILS'
      end

      option :name, 'developer_admin'
      option :email, DeveloperAdmin.admin_email
      option :users_name, 'Delia Veloper'

      uid { 'email' }

      def request_phase
        form = OmniAuth::Form.new(
          title: 'Default developer admin credentials – looked up from ADMIN_EMAILS env', url: callback_path
        )
        form.html <<~HTML
          <label for='email'>Email</label>
          <input type='text' id='email' name='email' value='#{options[:email]}' />
          <label for='name'>Name</label>
          <input type='text' id='name' name='name' value='#{options[:users_name]}' />
        HTML
        form.button 'Sign In'
        form.to_response
      end

      info do
        {
          name: request.params['name'],
          email: request.params['email']
        }
      end
    end
  end
end
