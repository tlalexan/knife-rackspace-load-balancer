require 'chef/knife'
require 'chef/knife/rackspace_base'
require 'chef/knife/rackspace_load_balancer_base'
require 'cloudlb'
module KnifePlugins
  class RackspaceLoadBalancerAddSsl < Chef::Knife
    include Chef::Knife::RackspaceBase
    include Chef::Knife::RackspaceLoadBalancerBase

    banner "knife rackspace load balancer add ssl LB_ID certificate_name"

    option :port,
      :long => "--port PORT",
      :description => "The port you want the balancer to listen to",
      :default => 443

    def run
      if @name_args.size < 2
        ui.fatal("Must provide lb_id and certifiate")
        show_usage
        exit 1
      end

      lb_id, cert_name = @name_args

      certs = Chef::Search::Query.new.search(:certs, "id:#{cert_name}")
      if certs[0].empty?
        ui.fatal("can't find #{cert_name} in data bags certs")
        exit 1
      end

      keys = Chef::Search::Query.new.search(:keys, "id:#{cert_name}")
      if keys[0].empty?
        ui.fatal("can't find #{cert_name} in data bags keys")
        exit 1
      end

      ssl_data = {
        :certificate => certs[0][0]['contents'],
        :privatekey => keys[0][0]['contents'],
        :securePort => config[:port]
      }

      load_balancer = CloudLB::Balancer.new(lb_connection, lb_id)
      load_balancer.create_ssl_termination(ssl_data)
      ui.output("success")
    end
  end
end

