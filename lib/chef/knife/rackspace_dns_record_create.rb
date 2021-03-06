require 'chef/knife'
require 'chef/knife/rackspace_base'
require 'chef/knife/rackspace_dns_base'

module KnifePlugins
  class RackspaceDnsRecordCreate < Chef::Knife

    include Chef::Knife::RackspaceBase
    include Chef::Knife::RackspaceDnsBase

    option :type,
           :short => "-t",
           :long => "--type TYPE",
           :description => "DNS record type (default: A)",
           :default => "A"

    option :ttl,
           :short => "-l",
           :long => "--ttl SECONDS",
           :description => "TTL in seconds (default 300)",
           :default => "300"

    option :server_name,
           :short => "-S",
           :long => "--server-name SERVER_NAME",
           :description => "Search for the Public IP of the rackspace server by name"

    banner "knife rackspace dns record create FQDN [VALUE]"

    def run
      $stdout.sync = true

      @fqdn = @name_args[0] 
      @value = @name_args[1] 

      if config[:server_name]
        @value = connection.servers.find { |s| s.name == config[:server_name] }.ipv4_address
      end

      if @fqdn.nil? || @value.nil?
        show_usage
        ui.fatal("You must specify an fqdn and a value ( either directly or via search )")
        exit 1
      end

      zone = zone_for @fqdn

      record = zone.records.create(:type => config[:type], :name => @fqdn, :value => @value, :ttl => config[:ttl])

      msg_pair("Zone", zone.domain)
      msg_pair("Name", record.name)
      msg_pair("Value", record.value)
      msg_pair("Type", record.type)
      msg_pair("TTL", record.ttl) 
    end

  end
end
    