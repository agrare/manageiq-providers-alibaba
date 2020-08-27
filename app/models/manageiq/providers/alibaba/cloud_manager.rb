class ManageIQ::Providers::Alibaba::CloudManager < ManageIQ::Providers::CloudManager
  require_nested :Refresher
  require_nested :RefreshWorker
  require_nested :Vm

  # Form schema for creating/editing a provider, it should follow the DDF specification
  # For more information check the DDF documentation at: https://data-driven-forms.org
  #
  # If for some reason some fields should not be included in the submitted data, there's
  # a `skipSubmit` flag. This is useful for components that provide local-only behavior,
  # like the validate-provider-credentials or protocol-selector.
  #
  # There's validation built on top on these fields in the API, so if some field isn't
  # specified here, the API endpoint won't allow the request to go through.
  # Make sure you don't dot-prefix match any field with any other field, because it can
  # confuse the validation. For example you should not have `x` and `x.y` fields at the
  # same time.
  def self.params_for_create
    @params_for_create ||= {
      :fields => [
        {
          :component => "text-field",
          :name      => "provider_region",
          :label     => _("Provider Region"),
          :isRequired => true,
          :validate   => [{:type => "required-validator"}],
          :options    => ManageIQ::Providers::Alibaba::Regions.all.sort_by { |r| r[:description] }.map do |region|
            {
              :label => region[:description],
              :value => region[:name]
            }
          end
        },
        {
          :component => 'sub-form',
          :name      => 'endpoints-subform',
          :title     => _('Endpoints'),
          :fields    => [
            {
              :component              => 'validate-provider-credentials',
              :name                   => 'authentications.default.valid',
              :skipSubmit             => true,
              :validationDependencies => %w[type provider_region],
              :fields                 => [
                {
                  :component  => "text-field",
                  :name       => "authentications.default.userid",
                  :label      => "Username",
                  :isRequired => true,
                  :validate   => [{:type => "required-validator"}],
                },
                {
                  :component  => "password-field",
                  :name       => "authentications.default.password",
                  :label      => "Password",
                  :type       => "password",
                  :isRequired => true,
                  :validate   => [{:type => "required-validator"}],
                },
              ]
            }
          ]
        }
      ]
    }
  end

  def self.verify_credentials(args)
    # Verify the credentials without having an actual record created.
    # This method is being called from the UI upon validation when adding/editing a provider via DDF
    # Ideally it should pass the args with some kind of mapping to the connect method
    region = args["provider_region"]
    default_endpoint = args.dig("authentications", "default")

    access_key_id, access_key_secret = default_endpoint&.values_at("userid", "password")
    access_key_secret = MiqPassword.try_decrypt(access_key_secret)

    !!raw_connect(region, access_key_id, access_key_secret)
  end

  def verify_credentials(auth_type = nil, options = {})
    begin
      connect
    rescue => err
      raise MiqException::MiqInvalidCredentialsError, err.message
    end

    true
  end

  def connect(options = {})
    raise MiqException::MiqHostError, "No credentials defined" if missing_credentials?(options[:auth_type])

    auth_token = authentication_token(options[:auth_type])
    self.class.raw_connect(project, auth_token, options, options[:proxy_uri] || http_proxy_uri)
  end

  def self.validate_authentication_args(params)
    # return args to be used in raw_connect
    return [params[:default_userid], ManageIQ::Password.encrypt(params[:default_password])]
  end

  def self.hostname_required?
    # TODO: ExtManagementSystem is validating this
    false
  end

  def self.raw_connect(*args)
    require "aliyunsdkcore"

    RPCClient.new(
      :endpoint          => "https://ecs.aliyuncs.com",
      :api_version       => "2014-05-26",
      :access_key_id     => access_key,
      :access_key_secret => secret_key
    )
  end

  def self.ems_type
    @ems_type ||= "alibaba".freeze
  end

  def self.description
    @description ||= "Alibaba".freeze
  end
end
