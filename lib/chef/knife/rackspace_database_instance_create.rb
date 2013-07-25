require 'chef/knife'
require 'chef/knife/rackspace_base'
require 'chef/knife/rackspace_database_base'
require 'chef/knife/rackspace_dns_base'

module KnifePlugins
  class RackspaceDatabaseInstanceCreate < Chef::Knife

    include Chef::Knife::RackspaceBase
    include Chef::Knife::RackspaceDatabaseBase
    include Chef::Knife::RackspaceDnsBase

    banner "knife rackspace database instance create INSTANCE_NAME"

    option :flavor,
           :short => "-f FLAVOR",
           :long => "--flavor FLAVOR",
           :description => "The flavor of server; default is 1 (512 MB)",
           :default => 1

    option :size,
           :short => "-s SIZE",
           :long => "--volume-size SIZE",
           :description => "The volume size of the database in gigabytes; default is 10",
           :default => 10

    option :instance_create_timeout,
           :long => "--instance-create-timeout timeout",
           :description => "How long to wait until the instance is ready; default is 600 seconds",
           :default => 600

    option :fqdn,
      :long => "-add-fqdn FQDN",
      :short => "-D FQDN",
      :description => "Creates an 'CNAME' record in Cloud DNS",
      :default => ""
           
    def run
      $stdout.sync = true

      if @name_args.first.nil?
        show_usage
        ui.error("INSTANCE_NAME is required")
        exit 1 
      end

      instance_name = @name_args.first

      instance = db_connection.instances.new(:name => instance_name,
                                         :flavor_id => config[:flavor],
                                         :volume_size => config[:size])
      instance.save

      msg_pair("Instance ID", instance.id)
      msg_pair("Name", instance.name)
      msg_pair("Flavor", instance.flavor.name)
      msg_pair("Volume Size", instance.volume_size)

      instance.wait_for(Integer(config[:instance_create_timeout])) { print "."; ready? }
      puts
      
      msg_pair("Hostname", instance.hostname)

      if (config[:fqdn])
        fqdn = config[:fqdn]
        fqdn_match = fqdn.match(/^([^.]*)\.(.*)$/i)
        if !fqdn_match
          ui.error("'#{fqdn}' is not a valid fqdn (e.g. test.example.com)")
          exit 1 
        end

        server_name, zone_name = fqdn_match.captures

        zone = dns_service.zones.find {|z| z.domain == zone_name }  

        if !zone
          ui.error("Could not find Rackspace DNS zone for '#{zone_name}'")
          exit 1 
        end

        zone.records.create(:type => 'CNAME', :name => fqdn, :value => instance.hostname)
        msg_pair("DNS", fqdn)
      end


      
    end

  end
end
