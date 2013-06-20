require 'chef/knife'
require 'chef/knife/rackspace_base'
require 'chef/knife/rackspace_load_balancer_base'
require 'cloudlb'
module KnifePlugins
  class RackspaceLoadBalancerAddMonitor < Chef::Knife
    include Chef::Knife::RackspaceBase
    include Chef::Knife::RackspaceLoadBalancerBase

    banner "knife rackspace load balancer add monitor LB_ID"

    option :type,
      :long => "--type CONNECT|HTTP|HTTPS",
      :description => "Type of health monitor to add.  CONNECT, HTTP, or HTTPS",
      :default => "CONNECT"

    option :delay,
      :long => "--delay SECONDS",
      :description => "The minimum number of seconds to wait before executing the health monitor. Must be a number between 1 and 3600. Default 10",
      :default => 10

    option :timeout,
      :long => "--timeout SECONDS",
      :description => "Maximum number of seconds to wait for a connection to be established before timing out. Must be a number between 1 and 300. Default 10",
      :default => 10,
      :required => false

    option :attemptsBeforeDeactivation,
      :long => "--attemptsBeforeDeactivation COUNT",
      :description => "Number of permissible monitor failures before removing a node from rotation. Must be a number between 1 and 10. Default 3",
      :default => 3

    option :bodyRegex,
           :long => "--bodyRegex REGEXP",
           :description => "A regular expression that will be used to evaluate the contents of the body of the response. HTTP/HTTPS only, required."

    option :hostHeader,
           :long => "--hostHeader hostname",
           :description => "The name of a host for which the health monitors will check.  HTTP/HTTPS only, optional."

    option :path,
           :long => "--path HTTP path",
           :description => "The HTTP path that will be used in the sample request.  HTTP/HTTPS only, required."

    option :statusRegex,
           :long => "--statusRegex REGEXP",
           :description => "A regular expression that will be used to evaluate the HTTP status code returned in the response.  HTTP/HTTPS only, required."


    def run
      if @name_args.size < 1
        ui.fatal("Must provide lb_id")
        show_usage
        exit 1
      end

      lb_id = @name_args[0]

      monitor_data = Hash.new
      monitor_data[:type] = config[:type]
      monitor_data[:delay] = config[:delay]
      monitor_data[:timeout] = config[:timeout]
      monitor_data[:attempts_before_deactivation] = config[:attemptsBeforeDeactivation]
      monitor_data[:bodyRegex] = config[:bodyRegex]
      monitor_data[:hostHeader] = config[:hostHeader]
      monitor_data[:path] = config[:path]
      monitor_data[:statusRegex] = config[:statusRegex]

      load_balancer_health = CloudLB::HealthMonitor.new(CloudLB::Balancer.new(lb_connection, lb_id))
      load_balancer_health.update(monitor_data)
      ui.output("success")
    end
  end
end

