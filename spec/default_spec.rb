require 'spec_helper'

describe 'chef-zero::default' do
  platforms = {
    'ubuntu' => ['10.04', '12.04'],
    'centos' => ['5.8', '6.3'],
  }

  platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::ChefRunner.new(platform: platform, version: version) do |node|
            node.override['chef-zero'] = {
              'install' => true,
              'start'   => true,
            }
          end.converge('chef-zero::default')
        end

        it 'uses the build-essential recipe' do
          expect(chef_run).to include_recipe('build-essential::default')
        end

        it 'installs the chef-zero gem' do
          expect(chef_run).to install_chef_gem_at_version('chef-zero', '1.5.1')
        end

        it 'drops the /etc/init.d script' do
          expect(chef_run).to create_file_with_content('/etc/init.d/chef-zero', '### BEGIN INIT INFO')
        end

        it 'sets the correct permissions' do
          expect(chef_run.template('/etc/init.d/chef-zero')).to be_owned_by('root', 'root')
        end

        it 'sets the correct mode' do
          expect(chef_run.template('/etc/init.d/chef-zero').mode).to eq('0755')
        end

        it 'starts the service' do
          expect(chef_run).to set_service_to_start_on_boot 'chef-zero'
        end
      end
    end
  end
end
