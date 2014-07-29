module ChefZeroCookbook
  module Helpers
    extend self

    # @return [Chef::Node]
    attr_reader :node

    # Generate the command string given the context of the node
    #
    # @param [Chef::Node] node
    #
    # @return [String]
    def command(node)
      @node = node

      if app['persist']
        cmd = "#{bin_path}/../embedded/bin/ruby  #{bin_path}/chef-zero-persist"
        cmd << " -- "
        cmd << " --repository #{app['repository_path']}"
      else
        cmd = "#{bin_path}/chef-zero"
      end

      cmd << " --host #{app['host']}"

      if app['listen'].to_i == 0 && !app['persist']
        cmd << " --socket #{app['listen']}"
      else
        cmd << " --port #{app['listen']}"
      end

      cmd << ' --generate-real-keys' if app['generate_real_keys']
      cmd << ' --daemon'
      cmd
    end

    def bin_path
      File.expand_path(File.join(
        node['chef_packages']['chef']['chef_root'],
        '..', '..', '..',
        '..', '..', '..', '..', '..', 'bin')
      )
    end

    private

    def app
      node['chef-zero']
    end
  end
end
