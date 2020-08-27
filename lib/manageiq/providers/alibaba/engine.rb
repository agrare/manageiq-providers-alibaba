module ManageIQ
  module Providers
    module Alibaba
      class Engine < ::Rails::Engine
        isolate_namespace ManageIQ::Providers::Alibaba

        config.autoload_paths << root.join('lib').to_s

        def self.vmdb_plugin?
          true
        end

        def self.plugin_name
          _('Alibaba Provider')
        end
      end
    end
  end
end
