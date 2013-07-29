require 'fog'

class Chef
  class Knife
    module RackspaceDnsBase

      def dns_service
          @dns_service ||= Fog::DNS::Rackspace.new(connection_params.except(:provider))
      end

      def zone_for(fqdn)
        parts = fqdn.split('.')
        if parts.count < fqdn_min_size
          ui.error("'#{fqdn}' is not a valid fqdn (e.g. test.example.com)")
          exit 1 
        end
        
        zone_name = parts.count > fqdn_min_size ? three_parts_zone_name(parts) : two_parts_zone_name(parts) 
        msg_pair("Zone_name", zone_name)
        zone = dns_service.zones.find {|z| z.domain == zone_name }  
        msg_pair("Zone", zone)
        zone
      end

      private

      def fqdn_min_size
        3
      end

      def three_parts_zone_name(parts)
        parts.last(3).join('.')
      end

      def two_parts_zone_name(parts)
        parts.last(2).join('.')
      end
    end
  end
end
