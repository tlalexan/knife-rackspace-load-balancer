class Chef
  class Knife
    module RackspaceLoadBalancerBase
      def self.included(base)
        base.class_eval do
          option :rackspace_region,
            :long => "--rackspace-region REGION",
            :description => "Your rackspace region",
            :default => "dfw",
            :proc => Proc.new { |region| Chef::Config[:knife][:rackspace_region] = region }
        end
      end
      def rackspace_api_credentials
        Chef::Log.debug("rackspace_api_username #{Chef::Config[:knife][:rackspace_api_username]}")
        Chef::Log.debug("rackspace_api_key #{Chef::Config[:knife][:rackspace_api_key]}")
        Chef::Log.debug("rackspace_region #{Chef::Config[:knife][:rackspace_region]}")
        {
          :username => Chef::Config[:knife][:rackspace_api_username],
          :api_key => Chef::Config[:knife][:rackspace_api_key],
          :region => Chef::Config[:knife][:rackspace_region]
        }
      end

      def lb_connection
        @lb_connection ||= CloudLB::Connection.new(rackspace_api_credentials)
      end
    end
  end
end
