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

    option :data_bag_name,
      :long => "--data-bag-name BAG",
      :description => "The name of the data bag you story ssl credentials in",
      :default => "ssl"

    def run
      if @name_args.size < 2
        ui.fatal("Must provide lb_id and certifiate")
        show_usage
        exit 1
      end

      lb_id, cert_name = @name_args
      data_bag_name = config[:data_bag_name].to_sym
      ssl = Chef::Search::Query.new.search(data_bag_name, "id:#{cert_name}")
      if ssl[0].empty?
        ui.fatal("can't find #{cert_name} in data bags ssl")
        exit 1
      end
      ssl_data = ssl[0][0].to_hash
      ssl_data[:securePort] = config[:port] 
      ssl_data.delete(:chef_type)
      ssl_data.delete(:data_bag)
      ssl_data.delete(:id)

      load_balancer = CloudLB::Balancer.new(lb_connection, lb_id)
      load_balancer.create_ssl_termination(ssl_data)
      ui.output("success")
    end
  end
end

