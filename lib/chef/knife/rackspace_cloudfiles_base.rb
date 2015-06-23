require 'fog'

class Chef
  class Knife
    module RackspaceCloudfilesBase

      def cloud_files_service
        @connection ||= Fog::Storage::Rackspace.new(connection_params.reject {|key, val| key == :provider}.merge({:rackspace_cdn_ssl => true}))
      end

    end
  end
end